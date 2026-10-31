# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

using Test, JSON, Random

@testset "live Amaquet server (destructive test namespace only)" begin
    uri = get(ENV, "AMAQUET_URI", "amaquet://127.0.0.1:13378")
    api_key = get(ENV, "AMAQUET_API_KEY", nothing)

    c = connect(
        uri;
        api_key = api_key,
        timeout = 15,
        require_identity = get(ENV, "AMAQUET_REQUIRE_IDENTITY", "0")=="1",
        identity_fingerprint = get(ENV, "AMAQUET_IDENTITY_FINGERPRINT", nothing),
    )

    try
        @test ping(c) == "PONG"
        registered = Set(types(c))

        @test all(t -> t in registered, Base.keys(TYPE_CATALOG))
        namespace = "julia-sdk-test:" * randstring(12) * ":"

        for t in sort(collect(Base.keys(TYPE_CATALOG)))
            s = JSON.parsefile(joinpath(@__DIR__, "fixtures", t*".json"))
            args = copy(s["construction"]["args"])
            args["key"] = namespace*t

            try
                command(c, s["construction"]["command"], args)
                @test typeofkey(c, args["key"]) == t

                snapshot = get(c, args["key"])
                @test typeofkey(c, args["key"]) == t

                if get(ENV, "AMAQUET_RUN_LIVE_OPERATIONS", "0")=="1"
                    for op in s["operations"]
                        opa = copy(op["args"])
                        opa["key"] = args["key"]

                        # May block or depend on prior state. Opt-in only.
                        command(c, "OP", opa)
                    end
                end
            finally
                try
                    delete!(c, args["key"])
                catch
                end
            end
        end

        payload = rand(Random.RandomDevice(), UInt8, 3*1024*1024 + 13)
        key = namespace*"blob"

        try
            upload_blob!(c, key, payload)
            @test download_blob!(c, key) == payload
        finally
            try
                delete!(c, key)
            catch
            end
        end
    finally
        close!(c)
    end
end
