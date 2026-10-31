# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

const MAGIC = UInt8[0x41, 0x4d, 0x51, 0x54]
const MAX_PAYLOAD = 64 * 1024 * 1024
const HEADER_SIZE = 24

const COMMANDS = (
    "PING",
    "SET",
    "CAS",
    "BATCH",
    "CREATE",
    "GET",
    "DEL",
    "EXISTS",
    "TYPE",
    "TTL",
    "EXPIRE",
    "PERSIST",
    "KEYS",
    "SCAN",
    "BLOB_BEGIN",
    "BLOB_CHUNK",
    "BLOB_COMMIT",
    "BLOB_READ",
    "BLOB_ABORT",
    "TYPES",
    "INFO",
    "MEMORY",
    "OP",
)

"""
ProtocolError: Represents an Amaquet protocol error with diagnostic information for callers; avoid logging credentials or private payloads.
Handles Amaquet binary frames and JSON payloads. Invalid lengths, types, and protocol versions must fail before allocation.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct ProtocolError <: Exception
    message::String
end
Base.showerror(io::IO, e::ProtocolError) = print(io, "Amaquet protocol: ", e.message)

"""
SecurityError: Represents an Amaquet security error with diagnostic information for callers; avoid logging credentials or private payloads.
Handles Amaquet binary frames and JSON payloads. Invalid lengths, types, and protocol versions must fail before allocation.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct SecurityError <: Exception
    message::String
end
Base.showerror(io::IO, e::SecurityError) = print(io, "Amaquet security: ", e.message)

"""
ClientClosedError: Represents an Amaquet client closed error with diagnostic information for callers; avoid logging credentials or private payloads.
Handles Amaquet binary frames and JSON payloads. Invalid lengths, types, and protocol versions must fail before allocation.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct ClientClosedError <: Exception
    message::String
end
Base.showerror(io::IO, e::ClientClosedError) = print(io, "Amaquet connection closed: ", e.message)

"""
ServerError: Represents an Amaquet server error with diagnostic information for callers; avoid logging credentials or private payloads.
Handles Amaquet binary frames and JSON payloads. Invalid lengths, types, and protocol versions must fail before allocation.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct ServerError <: Exception
    code::String
    message::String
end
Base.showerror(io::IO, e::ServerError) = print(io, "Amaquet ", e.code, ": ", e.message)

"""
Frame: Provides the Frame operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Handles Amaquet binary frames and JSON payloads. Invalid lengths, types, and protocol versions must fail before allocation.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct Frame
    kind::UInt8
    flags::UInt16
    opcode::UInt16
    request_id::UInt64
    payload::Vector{UInt8}
end

"""
Frame: Provides the Frame operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function Frame(
    kind::Integer, opcode::Integer, request_id::Integer, payload::Vector{UInt8}; flags = 0
)
    return Frame(UInt8(kind), UInt16(flags), UInt16(opcode), UInt64(request_id), payload)
end

"""
_putbe!: Provides the putbe! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Parameter `out`: Destination to decode the server response; preserve numeric precision.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _putbe!(out::Vector{UInt8}, pos::Int, v::Integer, count::Int)
    u = UInt64(v)
    for j in 0:(count - 1)
        out[pos + j] = UInt8((u >> (8 * (count-j-1))) & 0xff)
    end
end

"""
_getbe: Provides the getbe operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _getbe(b::AbstractVector{UInt8}, pos::Int, n::Int)
    x = UInt64(0)
    for i in pos:(pos + n - 1)
        x = (x << 8) | b[i]
    end
    return x
end

"""
encode_frame: Serialize the full fixed-header Amaquet frame and append its payload.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function encode_frame(f::Frame; max_payload::Int = MAX_PAYLOAD)
    0 <= length(f.payload) <= min(MAX_PAYLOAD, max_payload) ||
        throw(ProtocolError("payload too large"))
    f.kind in (0x01, 0x02, 0x03) || throw(ProtocolError("invalid frame kind"))

    out = zeros(UInt8, HEADER_SIZE + length(f.payload))
    out[1:4] = MAGIC
    out[5] = 0x01
    out[6] = f.kind

    _putbe!(out, 7, f.flags, 2)
    _putbe!(out, 9, f.opcode, 2)
    _putbe!(out, 13, f.request_id, 8)
    _putbe!(out, 21, length(f.payload), 4)

    if !isempty(f.payload)
        copyto!(out, HEADER_SIZE + 1, f.payload, 1, length(f.payload))
    end

    return out
end

"""
decode_frame: Read and validate a native frame, including protocol version, declared payload length, and request identifier.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function decode_frame(io::IO; max_payload::Int = MAX_PAYLOAD)
    h = read(io, HEADER_SIZE)

    """
    length: Provides the length operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
    Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
    Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    length(h) == HEADER_SIZE || throw(EOFError())

    h[1:4] == MAGIC || throw(ProtocolError("invalid frame magic"))
    h[5] == 0x01 || throw(ProtocolError("unsupported protocol version"))
    h[6] in (0x02, 0x03, 0x01) || throw(ProtocolError("invalid frame kind"))
    h[11:12] == UInt8[0, 0] || throw(ProtocolError("reserved bytes are not zero"))

    n = Int(_getbe(h, 21, 4))
    n <= min(MAX_PAYLOAD, max_payload) || throw(ProtocolError("payload exceeds limit"))
    body = read(io, n)

    """
    length: Provides the length operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
    Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
    Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    length(body) == n || throw(EOFError())
    return Frame(h[6], UInt16(_getbe(h, 7, 2)), UInt16(_getbe(h, 9, 2)), _getbe(h, 13, 8), body)
end

"""
Endpoint: Provides the Endpoint operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Handles Amaquet binary frames and JSON payloads. Invalid lengths, types, and protocol versions must fail before allocation.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct Endpoint
    tls::Bool
    host::String
    port::Int
end

"""
parse_endpoint: Parse an amaquet:// or amaquets:// address and reject unsupported schemes and paths.
Binary transfers use staged IDs and bounded chunks; abort incomplete uploads and verify range limits.
Protocol v1 frames use a fixed 24-byte header and a maximum 64 MiB payload; reject malformed frames.
Parameter `uri`: Native Amaquet URI. Use amaquets:// for TLS.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function parse_endpoint(uri::AbstractString)
    m = match(r"^(amaquets?)://(\[[0-9a-fA-F:.%]+\]|[^:/?#@]+)(?::([0-9]+))?/?$", String(uri))
    m === nothing && throw(
        ArgumentError(
            "expected amaquet://host[:port] or amaquets://host[:port] (credentials and paths are prohibited)",
        ),
    )

    port = isnothing(m.captures[3]) ? 13378 : tryparse(Int, m.captures[3])
    (port isa Int && 1 <= port <= 65535) || throw(ArgumentError("invalid Amaquet port"))

    host = String(m.captures[2])
    startswith(host, "[") && (host = host[2:(end - 1)])

    return Endpoint(m.captures[1] == "amaquets", host, port)
end
