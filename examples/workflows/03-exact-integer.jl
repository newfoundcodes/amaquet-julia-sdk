# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# 03-exact-integer
using Amaquet, JSON, Random

uri = get(ENV, "AMAQUET_URI", "amaquet://127.0.0.1:13378")
api_key = get(ENV, "AMAQUET_API_KEY", nothing)
c = connect(uri; api_key = api_key)

try
    key = "julia-demo:" * randstring(8)
    set!(c, key, "big_integer", "1234567890123456789012345678901234567890")

    println(get(c, key))
    delete!(c, key)
finally
    close!(c)
end
