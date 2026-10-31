# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# 34-read-ops
using Amaquet, JSON, Random

uri = get(ENV, "AMAQUET_URI", "amaquet://127.0.0.1:13378")
api_key = get(ENV, "AMAQUET_API_KEY", nothing)
c = connect(uri; api_key = api_key)

try
    key = "julia-counter:" * randstring(8)
    h = atomic_counter(c, key)

    try
        create!(h; options = Dict("initial"=>10))
        println(Amaquet.op_add(h, Dict("delta"=>5)))
        println(Amaquet.op_load(h))
    finally
        try
            delete!(h)
        catch
        end
    end
finally
    close!(c)
end
