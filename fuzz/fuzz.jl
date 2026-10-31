# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

using Amaquet
using Random
using JSON

const TARGETS = (
    "frame_magic",
    "frame_version",
    "frame_kind",
    "frame_flags",
    "frame_opcode",
    "frame_reserved",
    "frame_id",
    "frame_length",
    "frame_truncation",
    "frame_payload",
    "endpoint",
    "json_command",
    "blob_ranges",
)

function run_one(rng::AbstractRNG, target::String)
    valid = encode_frame(Frame(2, 1, rand(rng, UInt64), rand(rng, UInt8, rand(rng, 0:400))))
    if target == "endpoint"
        uri = rand(
            rng,
            [
                "amaquet://localhost",
                "amaquets://[::1]:13378",
                "http://wrong",
                "amaquet://127.0.0.1:0",
                "amaquet://host/db",
                "amaquet://host:65535",
            ],
        )

        try
            ep = parse_endpoint(uri)
            @assert 1 <= ep.port <= 65535
        catch e
            e isa ArgumentError || rethrow()
        end
    elseif target == "json_command"
        x = Dict("command"=>rand(rng, COMMANDS), "args"=>Dict("n"=>big(2)^rand(rng, 60:200)))

        decoded = JSON.parse(JSON.json(x))
        @assert decoded["command"] == x["command"]
    elseif target == "blob_ranges"
        offset = rand(rng, -100:100)
        n = rand(rng, -100:100)

        @assert (offset >= 0 && 0 <= n <= Amaquet.MAX_BLOB_READ) || !(offset >= 0 && n >= 0)
    else
        b = copy(valid)
        if target == "frame_magic"
            b[rand(rng, 1:4)] = rand(rng, UInt8)
        elseif target == "frame_version"
            b[5] = rand(rng, UInt8)
        elseif target == "frame_kind"
            b[6] = rand(rng, UInt8)
        elseif target == "frame_flags"
            b[7:8] = rand(rng, UInt8, 2)
        elseif target == "frame_opcode"
            b[9:10] = rand(rng, UInt8, 2)
        elseif target == "frame_reserved"
            b[11] = rand(rng, UInt8)
        elseif target == "frame_id"
            b[13:20] = rand(rng, UInt8, 8)
        elseif target == "frame_length"
            b[21:24] = rand(rng, UInt8, 4)
        elseif target == "frame_truncation"
            b = b[1:rand(rng, 0:length(b))]
        elseif target == "frame_payload"
            b = rand(rng, UInt8, rand(rng, 0:400))
        end

        try
            f = decode_frame(IOBuffer(b); max_payload = 1024)

            @assert 0 <= length(f.payload) <= 1024
            @assert f.kind in (1, 2, 3)
        catch e
            e isa ProtocolError || e isa EOFError || rethrow()
        end
    end
    return nothing
end

n = length(ARGS) > 0 ? parse(Int, ARGS[1]) : 2000
1 <= n <= 100000 || error("case count must be between 1 and 100000")

for (i, target) in enumerate(TARGETS)
    rng = MersenneTwister(44031+i)
    for _ in 1:n
        run_one(rng, target)
    end

    println("PASS $target ($n cases)")
end

println("TOTAL $(length(TARGETS)*n) generated fuzz cases")
