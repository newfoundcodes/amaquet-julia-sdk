# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# Amaquet t_digest: server-backed construction and optional operations.
using Amaquet, JSON, Random

uri = get(ENV, "AMAQUET_URI", "amaquet://127.0.0.1:13378")
c = connect(uri; api_key = get(ENV, "AMAQUET_API_KEY", nothing))
scene = JSON.parsefile(joinpath(@__DIR__, "..", "..", "test", "fixtures", "t_digest.json"))
key = "julia-example:t_digest:" * randstring(10)
args = copy(scene["construction"]["args"])

args["key"] = key
try
    command(c, scene["construction"]["command"], args)

    handle = t_digest(c, key)
    println("Type: ", handle.wire_type, " Snapshot: ", snapshot(handle))

    if get(ENV, "AMAQUET_RUN_EXAMPLE_OPERATIONS", "0") == "1"
        # Some operations block or mutate state. Only run when explicitly enabled.
        for request in scene["operations"]
            op = copy(request["args"])
            op["key"] = key

            println(command(c, "OP", op))
        end
    end
finally
    try
        delete!(c, key)
    catch
    end
    close!(c)
end
