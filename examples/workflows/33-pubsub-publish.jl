# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# 33-pubsub-publish
using Amaquet, JSON, Random

uri = get(ENV, "AMAQUET_URI", "amaquet://127.0.0.1:13378")
api_key = get(ENV, "AMAQUET_API_KEY", nothing)
c = connect(uri; api_key = api_key)

try
    key = "julia-pubsub:" * randstring(8)
    create!(c, key, "pubsub")

    sub = subscribe!(c, key, "updates")
    try
        println(
            operation(
                c,
                key,
                "PUBLISH",
                Dict("channel"=>"updates", "value"=>Dict("type"=>"utf8_string", "value"=>"hi")),
            ),
        )
        println(poll!(sub; timeout = 1))
    finally
        unsubscribe!(c, sub)
        delete!(c, key)
    end
finally
    close!(c)
end
