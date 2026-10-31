# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

using Test
using Amaquet
using Random
using JSON
using Sockets: Sockets
using Sockets: @ip_str

include("mock.jl")

@testset "Amaquet Julia SDK" begin
    @testset "wire protocol" begin
        data = UInt8[0x00, 0x01, 0xfe, 0xff]
        f = Frame(1, 1, 0x1122334455667788, data)

        encoded = encode_frame(f)
        @test length(encoded) == 28
        @test encoded[1:4] == collect(codeunits("AMQT"))
        @test encoded[5] == 1
        @test encoded[11:12] == [0, 0]
        @test encoded[13:20] == UInt8[0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88]

        round = decode_frame(IOBuffer(encoded))
        @test round.request_id == f.request_id
        @test round.payload == data
        @test round.opcode == f.opcode
        @test_throws ProtocolError decode_frame(IOBuffer(vcat(UInt8[0, 0, 0, 0], encoded[5:end])))
        @test_throws ProtocolError decode_frame(
            IOBuffer(vcat(encoded[1:20], UInt8[0xff, 0xff, 0xff, 0xff]))
        )
        @test_throws EOFError decode_frame(IOBuffer(encoded[1:7]))
        @test_throws ProtocolError encode_frame(
            Frame(1, 1, 1, fill(UInt8(0), 100)); max_payload = 32
        )
    end

    @testset "arbitrary precision number JSON" begin
        huge = parse(BigInt, "340282366920938463463374607431768211456")
        parsed = JSON.parse(JSON.json(Dict("n" => huge)))

        @test parsed["n"] == huge
        @test JSON.parse(JSON.json(Dict("n" => 0)))["n"] == 0
    end

    @testset "endpoint validation" begin
        ep = parse_endpoint("amaquet://localhost")
        @test ep.port == 13378
        @test !ep.tls
        @test parse_endpoint("amaquets://[::1]:9876").tls
        @test parse_endpoint("amaquet://127.0.0.1:2000").port == 2000

        for invalid in (
            "http://localhost",
            "amaquet://",
            "amaquet://host:0",
            "amaquet://host:70000",
            "amaquet://user@host",
            "amaquet://host/mydb",
        )
            @test_throws ArgumentError parse_endpoint(invalid)
        end
    end

    @testset "catalog and operation methods" begin
        @test length(TYPE_CATALOG) == 91
        @test OPERATION_COUNT == 242
        @test length(COMMANDS) == 23
        @test length(ADMIN_ROUTES) == 33

        mock = mock_native()
        c = connect("amaquet://127.0.0.1:$(mock.port)")

        try
            @test ping(c) == "PONG"
            @test length(types(c)) == 91
            @test isempty(Amaquet.get(c, "missing")) == false # mock echoes payload

            for (wire_type, ops) in sort(collect(TYPE_CATALOG); by = first)
                h = typed(c, wire_type, "test:$wire_type")
                @test h.wire_type == wire_type
                @test h.key == "test:$wire_type"
                @test typeofkey(c, h.key)["args"]["key"] == h.key

                for op in ops
                    method = Symbol("op_", lowercase(op))
                    fn = getfield(Amaquet, method)
                    result = fn(h, Dict("fixture"=>true))

                    @test result["args"]["operation"] == op
                    @test result["args"]["args"]["fixture"] === true
                    @test result["args"]["key"] == h.key
                end
            end

            for wire_type in sort(collect(keys(TYPE_CATALOG)))
                scene = JSON.parsefile(joinpath(@__DIR__, "fixtures", "$wire_type.json"))
                @test scene["type"] == wire_type

                construct = scene["construction"]
                result = command(c, construct["command"], construct["args"])
                @test result["command"] == construct["command"]
                @test result["args"] == construct["args"]

                # Replay all 242 documented argument fixtures through named methods.
                h = typed(c, wire_type, "test:$wire_type")

                for fixture in scene["operations"]
                    operation_name = fixture["args"]["operation"]
                    method = getfield(Amaquet, Symbol("op_", lowercase(operation_name)))
                    payload = method(h, fixture["args"]["args"])

                    @test payload["args"]["operation"] == operation_name
                    @test payload["args"]["args"] == fixture["args"]["args"]
                end
            end
        finally
            close!(c)
            stop_mock!(mock)
        end
    end

    @testset "out-of-order replies and auth" begin
        mock = mock_native(reverse_pair = true)
        c = connect("amaquet://127.0.0.1:$(mock.port)"; api_key = "test-api-key")

        try
            id1, ch1 = submit(c, 1, Dict("command"=>"PING", "args"=>Dict()))
            id2, ch2 = submit(c, 1, Dict("command"=>"PING", "args"=>Dict()))

            @test await_response(c, id2, ch2) == "PONG"
            @test await_response(c, id1, ch1) == "PONG"
            @test isempty(c.pending)
        finally
            close!(c)
            stop_mock!(mock)
        end
    end

    @testset "signed identity failure is closed" begin
        @test_throws SecurityError Amaquet._verify_identity(
            Dict("selected_protocol"=>1), "nonce"; require_identity = true
        )

        @test_throws SecurityError Amaquet._verify_identity(
            Dict(
                "identity_public_key"=>"not/base64",
                "nonce_signature"=>"a",
                "identity_fingerprint"=>"x",
            ),
            "nonce";
            require_identity = true,
        )
    end

    @testset "subscription queue bound" begin
        s = Subscription(1, "messages", "updates", 3, Any[], ReentrantLock(), 0, true)
        for i in 1:15
            Amaquet._event!(s, i)
        end

        @test dropped(s) == 12
        @test [poll!(s) for _ in 1:3] == [13, 14, 15]
        @test poll!(s) === nothing
    end

    @testset "blob range and payload validation" begin
        mock = mock_native()
        c = connect("amaquet://127.0.0.1:$(mock.port)")

        try
            @test_throws ArgumentError blob_begin!(c, "bad", -1)
            @test_throws ArgumentError blob_chunk!(c, "id", -1, UInt8[1])

            r = blob_begin!(c, "blob", 10)
            @test length(r["args"]["upload_id"]) == 32
            @test r["args"]["total_size"] == 10
            @test blob_chunk!(c, r["args"]["upload_id"], 0, UInt8[1, 2])["args"]["data"] == "AQI="
            @test blob_commit!(c, r["args"]["upload_id"])["command"] == "BLOB_COMMIT"
            @test download_blob!(c, "empty") == UInt8[]
        finally
            close!(c)
            stop_mock!(mock)
        end
    end

    @testset "HTTP path and redirects are rejected" begin
        a = AdminClient("http://127.0.0.1:1"; bearer_token = "test")
        @test Amaquet._pct_encode("a/b ?&") == "a%2Fb%20%3F%26"
        @test_throws ArgumentError admin_request(a, "GET", "/../secrets")
        @test_throws ArgumentError admin_request(a, "TRACE", "/api/health")
        @test_throws SecurityError AdminClient("http://example.org"; bearer_token = "token")
        @test_throws ArgumentError AdminClient("https://user:secret@example.org")
    end
end

include("admin_tests.jl")

# Live suite deliberately opts in and can change/delete server keys.
if get(ENV, "AMAQUET_RUN_LIVE", "") == "1"
    include("live.jl")
end
