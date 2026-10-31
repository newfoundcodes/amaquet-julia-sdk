# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# 29-bloom
using Amaquet, JSON, Random

uri = get(ENV, "AMAQUET_URI", "amaquet://127.0.0.1:13378")
api_key = get(ENV, "AMAQUET_API_KEY", nothing)
c = connect(uri; api_key = api_key)

try
    s = JSON.parsefile(joinpath(@__DIR__, "..", "..", "test", "fixtures", "hashmap.json"))
    args = copy(s["construction"]["args"])
    args["key"] = "julia-workflow:hashmap:" * randstring(8)

    try
        command(c, s["construction"]["command"], args)
        println(get(c, args["key"]))
    finally
        try
            delete!(c, args["key"])
        catch
        end
    end
finally
    close!(c)
end
