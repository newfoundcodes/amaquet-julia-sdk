# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# 14-blob-upload
using Amaquet, JSON, Random

uri = get(ENV, "AMAQUET_URI", "amaquet://127.0.0.1:13378")
api_key = get(ENV, "AMAQUET_API_KEY", nothing)
c = connect(uri; api_key = api_key)

try
    key = "julia-blob:" * randstring(8)
    bytes = rand(RandomDevice(), UInt8, 512*1024+13)

    try
        upload_blob!(c, key, bytes)
        received = download_blob!(c, key)

        @assert bytes == received
        println("Transferred ", length(bytes), " binary bytes")
    finally
        try
            delete!(c, key)
        catch
        end
    end
finally
    close!(c)
end
