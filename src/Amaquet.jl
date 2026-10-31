# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

module Amaquet

import Base: get, keys, delete!, lock, float

using Sockets: Sockets
using JSON: JSON
using Base64
using Random
using SHA
using Libdl
using Downloads: Downloads
using MbedTLS: MbedTLS

include("Codec.jl")
include("Native.jl")
include("Typed.jl")
include("Blobs.jl")
include("Admin.jl")
include("Pool.jl")

export Frame,
    ProtocolError,
    ServerError,
    SecurityError,
    ClientClosedError,
    Endpoint,
    parse_endpoint,
    encode_frame,
    decode_frame,
    MAX_PAYLOAD,
    NativeClient,
    connect,
    close!,
    request,
    command,
    submit,
    await_response,
    cancel!,
    hello!,
    authenticate!,
    subscribe!,
    unsubscribe!,
    poll!,
    dropped,
    Subscription,
    ping,
    set!,
    get,
    create!,
    cas!,
    batch!,
    delete!,
    exists,
    typeofkey,
    ttl,
    expire!,
    persist!,
    keys,
    scan,
    types,
    info,
    memory,
    operation,
    typed,
    typehandle,
    tuple_type,
    blob_begin!,
    blob_chunk!,
    blob_commit!,
    blob_abort!,
    blob_read,
    upload_blob!,
    download_blob!,
    upload_file!,
    download_file!,
    AdminClient,
    admin_request,
    ConnectionPool,
    checkout,
    release!,
    with_client,
    TYPE_CATALOG,
    OPERATION_COUNT,
    COMMANDS,
    ADMIN_ROUTES,
    typed_handle,
    snapshot
end
