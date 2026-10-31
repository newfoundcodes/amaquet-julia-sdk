# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# Thread-safe request multiplexing over a single TCP/TLS connection.
# A single background task owns reads. Writes and request allocation are locked.

"""
Subscription: Provides the Subscription operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Implements framed native commands over TCP/TLS with request multiplexing, server identity checks, bounded payloads, and explicit resource lifecycle.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
mutable struct Subscription
    id::UInt64
    key::String
    channel::String
    limit::Int
    events::Vector{Any}
    events_lock::ReentrantLock
    dropped_count::Int
    active::Bool
end

"""
dropped: Provides the dropped operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function dropped(s::Subscription)
    lock(s.events_lock) do
        return s.dropped_count
    end
end

"""
_event!: Provides the event! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _event!(s::Subscription, event)
    lock(s.events_lock) do
        s.active || return nothing
        if length(s.events) >= s.limit
            popfirst!(s.events)
            s.dropped_count += 1
        end

        return push!(s.events, event)
    end
end

"""
poll!: Provides the poll! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `timeout`: Time budget for the request; timeout does not guarantee server-side cancellation.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function poll!(s::Subscription; timeout::Real = 0)
    timeout >= 0 || throw(ArgumentError("timeout must be nonnegative"))
    done = () -> lock(s.events_lock) do
        return !isempty(s.events) || !s.active
    end

    """
    timedwait: Provides the timedwait operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
    Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    timedwait(done, timeout; pollint = 0.005) == :ok || return nothing
    lock(s.events_lock) do
        return isempty(s.events) ? nothing : popfirst!(s.events)
    end
end

"""
NativeClient: Provides the Native Client operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Implements framed native commands over TCP/TLS with request multiplexing, server identity checks, bounded payloads, and explicit resource lifecycle.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
mutable struct NativeClient
    transport::IO
    socket::Sockets.TCPSocket
    write_lock::ReentrantLock
    state_lock::ReentrantLock
    pending::Dict{UInt64,Channel{Any}}
    subscriptions::Dict{UInt64,Subscription}
    next_id::UInt64
    reader::Union{Task,Nothing}
    isclosed::Bool
    timeout::Float64
    max_inflight::Int
    max_payload::Int
    server_info::Any
    tls_state::Any
end

"""
_tls_connect: Provides the tls connect operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _tls_connect(sock::Sockets.TCPSocket, hostname::String)
    # Verification and hostname binding are both required; no insecure bypass.
    entropy = MbedTLS.Entropy()
    rng = MbedTLS.CtrDrbg()
    MbedTLS.seed!(rng, entropy)

    conf = MbedTLS.SSLConfig()
    MbedTLS.config_defaults!(conf)
    MbedTLS.authmode!(conf, MbedTLS.MBEDTLS_SSL_VERIFY_REQUIRED)
    MbedTLS.rng!(conf, rng)
    MbedTLS.ca_chain!(conf)

    ssl = MbedTLS.SSLContext()
    MbedTLS.setup!(ssl, conf)
    MbedTLS.hostname!(ssl, hostname)
    MbedTLS.set_bio!(ssl, sock)
    MbedTLS.handshake(ssl)

    return ssl, (entropy, rng, conf, ssl)
end

"""
_reader_loop: Reader loop using the implementation's validation, error, and resource-lifetime rules.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _reader_loop(c::NativeClient)
    try
        while true
            f = decode_frame(c.transport; max_payload = c.max_payload)
            if f.kind == 0x02
                ch = lock(c.state_lock) do
                    return pop!(c.pending, f.request_id, nothing)
                end

                ch === nothing && continue # Timed-out or already cancelled request.
                put!(ch, f)
            elseif f.kind == 0x03 && f.opcode == 0x04
                sub = lock(c.state_lock) do
                    return get(c.subscriptions, f.request_id, nothing)
                end

                sub === nothing || _event!(sub, JSON.parse(String(f.payload)))
            else
                throw(ProtocolError("unexpected frame kind or opcode"))
            end
        end
    catch e
        close!(c; reason = sprint(showerror, e))
    end
end

"""
connect: Open a connection, negotiate protocol version 1, verify requested server identity, and authenticate before returning a usable client.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `uri`: Native Amaquet URI. Use amaquets:// for TLS.
Parameter `api_key`: API key; keep credentials out of logs and version control.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function connect(
    uri::AbstractString;
    api_key::Union{Nothing,String} = nothing,
    timeout::Real = 10,
    max_inflight::Int = 128,
    max_payload::Int = MAX_PAYLOAD,
    require_identity::Bool = false,
    identity_fingerprint::Union{Nothing,String} = nothing,
    identity_public_key::Union{Nothing,String} = nothing,
)
    timeout > 0 || throw(ArgumentError("timeout must be positive"))
    max_inflight > 0 || throw(ArgumentError("max_inflight must be positive"))

    1 <= max_payload <= MAX_PAYLOAD || throw(ArgumentError("invalid max_payload"))
    ep = parse_endpoint(uri)
    sock = Sockets.connect(ep.host, ep.port)
    transport = sock
    tls_state = nothing

    try
        if ep.tls
            transport, tls_state = _tls_connect(sock, ep.host)
        end

        c = NativeClient(
            transport,
            sock,
            ReentrantLock(),
            ReentrantLock(),
            Dict{UInt64,Channel{Any}}(),
            Dict{UInt64,Subscription}(),
            0x0000000000000000,
            nothing,
            false,
            Float64(timeout),
            max_inflight,
            max_payload,
            nothing,
            tls_state,
        )
        c.reader = @async _reader_loop(c)

        try
            hello!(
                c;
                require_identity = require_identity,
                identity_fingerprint = identity_fingerprint,
                identity_public_key = identity_public_key,
            )
            api_key === nothing || authenticate!(c, api_key)
        catch
            close!(c)
            rethrow()
        end
        return c
    catch
        try
            close(transport)
        catch
        end
        try
            close(sock)
        catch
        end
        rethrow()
    end
end

"""
close!: Release network resources and notify waiting operations of connection shutdown.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function close!(c::NativeClient; reason::String = "closed")
    channels = Channel{Any}[]
    lock(c.state_lock) do
        c.isclosed && return nothing
        c.isclosed = true

        append!(channels, values(c.pending))
        empty!(c.pending)

        for s in values(c.subscriptions)
            lock(s.events_lock) do
                return s.active = false
            end
        end

        return empty!(c.subscriptions)
    end

    for ch in channels
        try
            put!(ch, ClientClosedError(reason))
        catch
        end
    end

    try
        close(c.transport)
    catch
    end

    try
        close(c.socket)
    catch
    end

    return nothing
end
Base.close(c::NativeClient) = close!(c)

"""
submit: Provides the submit operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function submit(
    c::NativeClient,
    opcode::Integer,
    payload = Dict{String,Any}();
    subscription::Union{Nothing,Subscription} = nothing,
)
    body = Vector{UInt8}(codeunits(JSON.json(payload)))
    length(body) <= c.max_payload || throw(ProtocolError("outbound payload too large"))

    ch = Channel{Any}(1)
    id = lock(c.state_lock) do
        c.isclosed && throw(ClientClosedError("closed"))
        length(c.pending) < c.max_inflight || throw(ProtocolError("too many in-flight requests"))

        c.next_id == typemax(UInt64) && throw(ProtocolError("request ID space exhausted"))
        c.next_id += UInt64(1)
        c.pending[c.next_id] = ch

        if subscription !== nothing
            subscription.id = c.next_id
            c.subscriptions[c.next_id] = subscription
        end

        return c.next_id
    end

    try
        lock(c.write_lock) do
            write(
                c.transport, encode_frame(Frame(1, opcode, id, body); max_payload = c.max_payload)
            )
            return flush(c.transport)
        end
    catch e
        lock(c.state_lock) do
            pop!(c.pending, id, nothing)
            return pop!(c.subscriptions, id, nothing)
        end

        close!(c; reason = "write failed")
        rethrow(e)
    end
    return (id, ch)
end

"""
await_response: Provides the await response operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `timeout`: Time budget for the request; timeout does not guarantee server-side cancellation.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function await_response(c::NativeClient, id::UInt64, ch::Channel; timeout::Real = c.timeout)
    timeout > 0 || throw(ArgumentError("timeout must be positive"))
    if timedwait(() -> isready(ch), timeout; pollint = 0.005) != :ok
        lock(c.state_lock) do
            return pop!(c.pending, id, nothing)
        end

        # Inform the server; do not block waiting for the cancellation reply.
        @async begin
            try
                cancel!(c, id)
            catch
                # Connection may already have closed, or CANCEL may itself time out.
            end
        end
        throw(ProtocolError("request $id timed out"))
    end

    frame = take!(ch)
    frame isa Exception && throw(frame)
    frame isa Frame || throw(ProtocolError("invalid pending result"))

    response = JSON.parse(String(frame.payload))
    response isa AbstractDict || throw(ProtocolError("invalid response JSON"))

    if get(response, "ok", false) !== true
        err = get(response, "error", Dict{String,Any}())
        throw(
            ServerError(
                string(get(err, "code", "ERROR")),
                string(get(err, "message", "server rejected request")),
            ),
        )
    end

    return get(response, "result", nothing)
end

"""
request: Submit an operation with a request ID and await its matching response or a timeout or connection error.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `timeout`: Time budget for the request; timeout does not guarantee server-side cancellation.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function request(
    c::NativeClient, opcode::Integer, payload = Dict{String,Any}(); timeout::Real = c.timeout
)
    id, ch = submit(c, opcode, payload)
    return await_response(c, id, ch; timeout = timeout)
end

"""
command: Send a named native command with its JSON payload; this is the extension point for supported server commands.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `timeout`: Time budget for the request; timeout does not guarantee server-side cancellation.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
Parameter `name`: Native command or type operation name sent to the server.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function command(
    c::NativeClient, name::AbstractString, args = Dict{String,Any}(); timeout::Real = c.timeout
)
    return request(
        c, 1, Dict("command" => uppercase(String(name)), "args" => args); timeout = timeout
    )
end

"""
cancel!: Provides the cancel! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function cancel!(c::NativeClient, id::Integer)
    return request(c, 6, Dict("request_id" => UInt64(id)))
end

"""
_decode_rawbase64: Decode rawbase64 using the implementation's validation, error, and resource-lifetime rules.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _decode_rawbase64(text::AbstractString)
    b = String(text)
    return base64decode(b * repeat("=", mod(-ncodeunits(b), 4)))
end

"""
_verify_identity: Verify identity using the implementation's validation, error, and resource-lifetime rules.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _verify_identity(
    info,
    nonce::String;
    require_identity = false,
    identity_fingerprint = nothing,
    identity_public_key = nothing,
)
    pub64 = get(info, "identity_public_key", nothing)
    signature = get(info, "nonce_signature", nothing)
    fingerprint = get(info, "identity_fingerprint", nothing)
    must_verify =
        require_identity || identity_public_key !== nothing || identity_fingerprint !== nothing

    if !must_verify && pub64 === nothing
        return nothing
    end

    if pub64 === nothing || signature === nothing || fingerprint === nothing
        must_verify && throw(SecurityError("server did not provide a signed identity"))
        return nothing
    end

    pub, sig = try
        _decode_rawbase64(pub64), _decode_rawbase64(signature)
    catch
        throw(SecurityError("malformed Ed25519 identity"))
    end

    """
    length: Provides the length operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
    Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    length(pub) == 32 && length(sig) == 64 ||
        throw(SecurityError("invalid Ed25519 key/signature length"))
    expected = "ed25519:" * bytes2hex(sha256(pub))
    fingerprint == expected || throw(SecurityError("server identity fingerprint mismatch"))

    identity_public_key === nothing ||
        (identity_public_key == pub64 || throw(SecurityError("identity key pin mismatch")))

    identity_fingerprint === nothing || (
        identity_fingerprint == expected ||
        throw(SecurityError("identity fingerprint pin mismatch"))
    )

    # Verify whenever a signature is advertised; never silently ignore a bad signature.
    _sodium_ed25519_verify(pub, sig, Vector{UInt8}(codeunits(nonce))) ||
        throw(SecurityError("invalid nonce signature"))

    return nothing
end

"""
_sodium_ed25519_verify: Provides the sodium ed25519 verify operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _sodium_ed25519_verify(pub::Vector{UInt8}, sig::Vector{UInt8}, msg::Vector{UInt8})
    lib = Libdl.find_library(["libsodium", "libsodium.so.23", "libsodium.dylib", "libsodium.dll"])
    isempty(lib) && throw(SecurityError("libsodium is required for Ed25519 verification"))
    handle = Libdl.dlopen(lib)

    try
        verify_ptr = Libdl.dlsym(handle, :crypto_sign_verify_detached)
        ccall(
            verify_ptr,
            Cint,
            (Ptr{UInt8}, Ptr{UInt8}, Culonglong, Ptr{UInt8}),
            sig,
            msg,
            length(msg),
            pub,
        ) == 0
    finally
        Libdl.dlclose(handle)
    end
end

"""
hello!: Provides the hello! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function hello!(
    c::NativeClient;
    require_identity = false,
    identity_fingerprint = nothing,
    identity_public_key = nothing,
)
    nonce = randstring(Random.RandomDevice(), 64)
    info = request(c, 2, Dict("nonce" => nonce, "min_protocol" => 1, "max_protocol" => 1))
    info isa AbstractDict || throw(ProtocolError("invalid HELLO result"))

    """
    get: Read current data for a key or type-specific field, subject to server permissions and key existence.
    Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    get(info, "selected_protocol", nothing) == 1 ||
        throw(ProtocolError("incompatible server protocol"))
    _verify_identity(
        info,
        nonce;
        require_identity = require_identity,
        identity_fingerprint = identity_fingerprint,
        identity_public_key = identity_public_key,
    )

    c.server_info = info
    return info
end

"""
authenticate!: Provides the authenticate! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `api_key`: API key; keep credentials out of logs and version control.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function authenticate!(c::NativeClient, api_key::AbstractString)
    isempty(api_key) && throw(ArgumentError("empty API key"))
    response = request(c, 3, Dict("api_key" => String(api_key)))

    """
    get: Read current data for a key or type-specific field, subject to server permissions and key existence.
    Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    get(response, "authenticated", false) === true ||
        throw(SecurityError("server did not authenticate"))
    return response
end

"""
subscribe!: Provides the subscribe! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Parameter `buffer`: Bounded storage for incoming payloads or events.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function subscribe!(c::NativeClient, key::AbstractString, channel::AbstractString; buffer::Int = 64)
    1 <= buffer <= 65536 || throw(ArgumentError("subscription buffer must be between 1 and 65536"))

    # Event can arrive immediately after server response. Register queue before submit returns.
    sub = Subscription(0, String(key), String(channel), buffer, Any[], ReentrantLock(), 0, true)
    id, ch = submit(
        c, 4, Dict("key" => key, "channel" => channel, "buffer" => buffer); subscription = sub
    )

    try
        await_response(c, id, ch)
        return sub
    catch
        lock(c.state_lock) do
            return pop!(c.subscriptions, id, nothing)
        end
        sub.active = false
        rethrow()
    end
end

"""
unsubscribe!: Provides the unsubscribe! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function unsubscribe!(c::NativeClient, sub::Subscription)
    result = request(c, 5, Dict("key" => sub.key, "channel" => sub.channel))
    lock(c.state_lock) do
        return pop!(c.subscriptions, sub.id, nothing)
    end

    lock(sub.events_lock) do
        return sub.active = false
    end
    return result
end

"""
ping: Send a liveness probe. A successful response confirms the endpoint accepts this command.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
ping(c::NativeClient) = command(c, "PING")

"""
set!: Provides the set! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Parameter `value`: Data to write or transmit, using the wire-type JSON format.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function set!(c::NativeClient, key, wiretype, value; kwargs...)
    return command(
        c,
        "SET",
        merge(
            Dict("key"=>key, "type"=>wiretype, "value"=>value),
            Dict(string(k)=>v for (k, v) in kwargs),
        ),
    )
end

"""
get: Read current data for a key or type-specific field, subject to server permissions and key existence.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
get(c::NativeClient, key) = command(c, "GET", Dict("key"=>key))

"""
create!: Provides the create! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Parameter `options`: Call settings or documented construction flags, as accepted by this method.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function create!(c::NativeClient, key, wiretype; options = Dict{String,Any}(), kwargs...)
    return command(
        c,
        "CREATE",
        merge(
            Dict("key"=>key, "type"=>wiretype, "options"=>options),
            Dict(string(k)=>v for (k, v) in kwargs),
        ),
    )
end

"""
cas!: Provides the cas! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
cas!(c::NativeClient, args::AbstractDict) = command(c, "CAS", args)

"""
cas!: Provides the cas! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Parameter `value`: Data to write or transmit, using the wire-type JSON format.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function cas!(c::NativeClient, key, expected_version::Integer, wire_type, value)
    return cas!(
        c, Dict("key"=>key, "expected_version"=>expected_version, "type"=>wire_type, "value"=>value)
    )
end

"""
batch!: Provides the batch! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
batch!(c::NativeClient, args::AbstractDict) = command(c, "BATCH", args)

"""
batch!: Provides the batch! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function batch!(c::NativeClient, requests::AbstractVector; continue_on_error::Bool = false)
    return batch!(c, Dict("requests"=>requests, "continue_on_error"=>continue_on_error))
end

"""
delete!: Provides the delete! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
delete!(c::NativeClient, keys::AbstractVector) = command(c, "DEL", Dict("keys"=>keys))

"""
delete!: Provides the delete! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
delete!(c::NativeClient, key::AbstractString) = delete!(c, [String(key)])

"""
exists: Provides the exists operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
exists(c::NativeClient, key) = command(c, "EXISTS", Dict("key"=>key))

"""
typeofkey: Provides the typeofkey operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
typeofkey(c::NativeClient, key) = command(c, "TYPE", Dict("key"=>key))

"""
ttl: Provides the ttl operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
ttl(c::NativeClient, key) = command(c, "TTL", Dict("key"=>key))

"""
expire!: Provides the expire! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function expire!(c::NativeClient, key, ttl_ms::Integer)
    return command(c, "EXPIRE", Dict("key"=>key, "ttl_ms"=>ttl_ms))
end

"""
persist!: Provides the persist! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
persist!(c::NativeClient, key) = command(c, "PERSIST", Dict("key"=>key))

"""
keys: Provides the keys operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function keys(c::NativeClient; prefix = "", limit = 1000)
    return command(c, "KEYS", Dict("prefix"=>prefix, "limit"=>limit))
end

"""
scan: Provides the scan operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function scan(c::NativeClient; cursor = "", prefix = "", count = 100)
    return command(c, "SCAN", Dict("cursor"=>cursor, "prefix"=>prefix, "count"=>count))
end

"""
types: Provides the types operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
types(c::NativeClient) = command(c, "TYPES")

"""
info: Provides the info operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
info(c::NativeClient) = command(c, "INFO")

"""
memory: Provides the memory operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
memory(c::NativeClient, key) = command(c, "MEMORY", Dict("key"=>key))

"""
operation: Dispatch a typed OP command using the key, exact uppercase operation name, and server-defined argument map.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function operation(c::NativeClient, key, op::AbstractString, args = Dict{String,Any}())
    return command(c, "OP", Dict("key"=>key, "operation"=>uppercase(String(op)), "args"=>args))
end
