# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# The 2026-10-24 Go dispatcher requires an explicit upload_id.
const MAX_BLOB_BYTES = 1024 * 1024 * 1024
const MAX_BLOB_READ = 32 * 1024 * 1024

"""
blob_begin!: Provides the blob begin! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function blob_begin!(
    c::NativeClient,
    key::AbstractString,
    total_size::Integer;
    upload_id::String = bytes2hex(rand(Random.RandomDevice(), UInt8, 16)),
    connection_scoped::Bool = true,
    nx::Bool = false,
    xx::Bool = false,
)
    0 <= total_size <= MAX_BLOB_BYTES || throw(ArgumentError("blob must be between 0 and 1 GiB"))
    nx && xx && throw(ArgumentError("nx and xx cannot both be true"))

    return command(
        c,
        "BLOB_BEGIN",
        Dict(
            "key"=>key,
            "total_size"=>total_size,
            "upload_id"=>upload_id,
            "connection_scoped"=>connection_scoped,
            "nx"=>nx,
            "xx"=>xx,
        ),
    )
end

"""
blob_chunk!: Provides the blob chunk! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function blob_chunk!(
    c::NativeClient, upload_id::AbstractString, offset::Integer, data::AbstractVector{UInt8}
)
    offset >= 0 || throw(ArgumentError("negative blob offset"))
    length(data) <= MAX_BLOB_READ || throw(ArgumentError("chunk exceeds 32 MiB"))

    return command(
        c, "BLOB_CHUNK", Dict("upload_id"=>upload_id, "offset"=>offset, "data"=>base64encode(data))
    )
end

"""
blob_commit!: Provides the blob commit! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
blob_commit!(c::NativeClient, upload_id) = command(c, "BLOB_COMMIT", Dict("upload_id"=>upload_id))

"""
blob_abort!: Provides the blob abort! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
blob_abort!(c::NativeClient, upload_id) = command(c, "BLOB_ABORT", Dict("upload_id"=>upload_id))

"""
blob_read: Provides the blob read operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function blob_read(
    c::NativeClient, key::AbstractString; offset::Integer = 0, length::Integer = 1024*1024
)
    offset >= 0 || throw(ArgumentError("negative offset"))
    0 <= length <= MAX_BLOB_READ || throw(ArgumentError("invalid blob read length"))

    r = command(c, "BLOB_READ", Dict("key"=>key, "offset"=>offset, "length"=>length))
    r isa AbstractDict || throw(ProtocolError("invalid BLOB_READ response"))

    """
    get: Read current data for a key or type-specific field, subject to server permissions and key existence.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    get(r, "offset", nothing) == offset || throw(ProtocolError("BLOB_READ offset mismatch"))

    size = get(r, "size", nothing)
    size isa Integer && size >= 0 || throw(ProtocolError("invalid BLOB_READ size"))

    data = try
        base64decode(r["data"])
    catch
        throw(ProtocolError("invalid BLOB_READ base64"))
    end

    Base.length(data) <= length || throw(ProtocolError("server returned more data than requested"))
    offset + Base.length(data) <= size ||
        throw(ProtocolError("server returned data past object end"))

    return (data = data, size = Int(size), version = get(r, "version", nothing))
end

"""
upload_file!: Provides the upload file! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function upload_file!(
    c::NativeClient,
    key::AbstractString,
    io::IO,
    total_size::Integer;
    chunk_size::Int = 512*1024,
    kwargs...,
)
    1 <= chunk_size <= 4*1024*1024 || throw(ArgumentError("chunk_size must be between 1 and 4 MiB"))
    receipt = blob_begin!(c, key, total_size; kwargs...)

    id = String(receipt["upload_id"])
    offset = 0

    try
        while offset < total_size
            block = read(io, min(chunk_size, total_size-offset))
            isempty(block) && throw(EOFError())
            blob_chunk!(c, id, offset, block)
            offset += length(block)
        end
        return blob_commit!(c, id)
    catch
        try
            blob_abort!(c, id)
        catch
        end
        rethrow()
    end
end

"""
upload_blob!: Provides the upload blob! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function upload_blob!(c::NativeClient, key::AbstractString, bytes::AbstractVector{UInt8}; kwargs...)
    return upload_file!(c, key, IOBuffer(bytes), length(bytes); kwargs...)
end

"""
upload_file!: Provides the upload file! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function upload_file!(c::NativeClient, key::AbstractString, filename::AbstractString; kwargs...)
    open(filename, "r") do io
        return upload_file!(c, key, io, filesize(filename); kwargs...)
    end
end

"""
download_file!: Provides the download file! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function download_file!(c::NativeClient, key::AbstractString, io::IO; chunk_size::Int = 1024*1024)
    1 <= chunk_size <= MAX_BLOB_READ || throw(ArgumentError("invalid chunk_size"))
    offset, expected, expected_version = 0, nothing, nothing

    while true
        part = blob_read(c, key; offset = offset, length = chunk_size)
        if expected === nothing
            expected = part.size
            expected_version = part.version
        elseif expected != part.size || expected_version != part.version
            throw(ProtocolError("blob changed during download"))
        end

        write(io, part.data)

        offset += length(part.data)
        offset == expected && return expected
        offset < expected || throw(ProtocolError("blob download exceeded expected size"))

        isempty(part.data) && throw(ProtocolError("zero-length blob chunk before end"))
    end
end

"""
download_blob!: Provides the download blob! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function download_blob!(c::NativeClient, key::AbstractString; chunk_size::Int = 1024*1024)
    out = IOBuffer()
    download_file!(c, key, out; chunk_size = chunk_size)
    return take!(out)
end

"""
download_file!: Provides the download file! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function download_file!(c::NativeClient, key::AbstractString, filename::AbstractString; kwargs...)
    open(filename, "w") do io
        return download_file!(c, key, io; kwargs...)
    end
end
