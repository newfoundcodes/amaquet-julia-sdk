# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

# Administration runs over HTTP(S) on a separate port.
const ADMIN_ROUTES = Pair{String,String}[]  # Generated named methods populate this table.

"""
AdminClient: Provides the Admin Client operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Provides the separate HTTP control-plane API, including sessions, organizations, RBAC, API keys, audit, metrics, and configuration.
Control-plane requests use a separate HTTP(S) base URL and may require administrative authorization.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
mutable struct AdminClient
    base_url::String
    bearer_token::Union{Nothing,String}
    admin_token::Union{Nothing,String}
    session_cookie::Union{Nothing,String}
    timeout::Float64
    max_response_bytes::Int
    downloader::Downloads.Downloader
    lock::ReentrantLock
end

"""
AdminClient: Provides the Admin Client operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Control-plane requests use a separate HTTP(S) base URL and may require administrative authorization.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function AdminClient(
    base_url::AbstractString;
    bearer_token = nothing,
    admin_token = nothing,
    session_cookie = nothing,
    timeout::Real = 15,
    max_response_bytes::Int = 8*1024*1024,
    allow_insecure_credentials::Bool = false,
)
    url = rstrip(String(base_url), '/')
    occursin(r"^https?://[^/?#@]+(?::[0-9]+)?$", url) ||
        throw(ArgumentError("expected HTTP(S) administration base URL"))

    timeout > 0 || throw(ArgumentError("invalid HTTP timeout"))
    1 <= max_response_bytes <= MAX_PAYLOAD ||
        throw(ArgumentError("invalid HTTP response size limit"))

    credentials = bearer_token !== nothing || admin_token !== nothing || session_cookie !== nothing
    if credentials && startswith(url, "http://") && !allow_insecure_credentials
        host = replace(url[8:end], r":\d+$"=>"")
        host in ("127.0.0.1", "localhost", "[::1]") ||
            throw(SecurityError("admin credentials require HTTPS outside loopback"))
    end

    downloader = Downloads.Downloader()
    # Never follow redirects when sensitive authentication headers might be forwarded.
    downloader.easy_hook =
        (easy, info) -> Downloads.Curl.setopt(easy, Downloads.Curl.CURLOPT_FOLLOWLOCATION, 0)

    return AdminClient(
        url,
        bearer_token,
        admin_token,
        session_cookie,
        Float64(timeout),
        max_response_bytes,
        downloader,
        ReentrantLock(),
    )
end

# Percent-encode each query value or dynamic path segment; no raw user path segments.
"""
_pct_encode: Provides the pct encode operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _pct_encode(s)
    io = IOBuffer()
    for x in codeunits(string(s))
        if UInt8('A') <= x <= UInt8('Z') ||
            UInt8('a') <= x <= UInt8('z') ||
            UInt8('0') <= x <= UInt8('9') ||
            x in (0x2d, 0x2e, 0x5f, 0x7e)
            write(io, x)
        else
            print(io, '%', uppercase(string(x; base = 16, pad = 2)))
        end
    end
    return String(take!(io))
end

"""
_safeheader: Provides the safeheader operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `value`: Data to write or transmit, using the wire-type JSON format.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function _safeheader(value)
    s = string(value)
    (occursin('\r', s) || occursin('\n', s)) && throw(ArgumentError("invalid HTTP header"))
    return s
end

"""
_BoundedOutput: Provides the Bounded Output operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Provides the separate HTTP control-plane API, including sessions, organizations, RBAC, API keys, audit, metrics, and configuration.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
mutable struct _BoundedOutput <: IO
    storage::IOBuffer
    limit::Int
    count::Int
end

"""
_BoundedOutput: Provides the Bounded Output operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
_BoundedOutput(limit::Int) = _BoundedOutput(IOBuffer(), limit, 0)

"""
unsafe_write: Provides the unsafe write operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function Base.unsafe_write(o::_BoundedOutput, p::Ptr{UInt8}, n::UInt)
    n <= UInt(o.limit-o.count) || throw(ProtocolError("HTTP response exceeds size limit"))
    b = unsafe_wrap(Vector{UInt8}, p, Int(n); own = false)

    written = write(o.storage, b)
    o.count += written

    return UInt(written)
end

Base.isopen(o::_BoundedOutput) = isopen(o.storage)
Base.flush(o::_BoundedOutput) = flush(o.storage)
Base.close(o::_BoundedOutput) = close(o.storage)

"""
admin_request: Provides the admin request operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Control-plane requests use a separate HTTP(S) base URL and may require administrative authorization.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""

function admin_request(
    a::AdminClient,
    method::AbstractString,
    path::AbstractString;
    query = Dict{String,Any}(),
    body = nothing,
    headers = Pair{String,String}[],
)
    verb = uppercase(String(method))
    verb in ("GET", "POST", "PUT", "PATCH", "DELETE") ||
        throw(ArgumentError("invalid administration method"))
    p = String(path)

    startswith(p, '/') && !occursin("..", p) && !occursin('#', p) && !occursin('?', p) ||
        throw(ArgumentError("invalid administration path"))

    q = sort(collect(pairs(query)); by = x->string(first(x)))
    qs = isempty(q) ? "" : "?" * join((_pct_encode(k)*"="*_pct_encode(v) for (k, v) in q), "&")
    url = a.base_url * p * qs
    h = Pair{String,String}["Accept" => (p == "/metrics" ? "text/plain" : "application/json")]

    a.bearer_token === nothing || push!(h, "Authorization"=>"Bearer "*_safeheader(a.bearer_token))
    a.admin_token === nothing || push!(h, "X-Amaquet-Admin-Token"=>_safeheader(a.admin_token))
    a.session_cookie === nothing ||
        push!(h, "Cookie"=>"amaquet_session="*_safeheader(a.session_cookie))
    append!(h, headers)

    data = nothing
    if body !== nothing
        push!(h, "Content-Type"=>"application/json")
        data = IOBuffer(JSON.json(body))
    end

    dest = _BoundedOutput(a.max_response_bytes)
    res = Downloads.request(
        url;
        method = verb,
        headers = h,
        input = data,
        output = dest,
        timeout = a.timeout,
        throw = false,
        downloader = a.downloader,
    )

    # Downloads returns a Response for HTTP status errors with throw=false.
    res isa Downloads.RequestError && throw(ProtocolError("HTTP transport: " * res.message))
    300 <= res.status < 400 && throw(ProtocolError("HTTP redirect rejected"))
    bytes = take!(dest.storage)
    content = if isempty(bytes)
        nothing

    elseif p == "/metrics"
        String(bytes)
    else
        try
            JSON.parse(String(bytes))
        catch
            throw(ProtocolError("invalid JSON from administration API"))
        end
    end
    
    if res.status < 200 || res.status >= 300
        throw(ServerError("HTTP_$(res.status)", string(content)))
    end
    
    for (k, v) in res.headers
        if lowercase(k) == "set-cookie" && startswith(v, "amaquet_session=")
            value = split(split(v, ';'; limit = 2)[1], '='; limit = 2)
            if length(value) == 2
                lock(a.lock) do
                    return a.session_cookie = isempty(value[2]) ? nothing : value[2]
                end
            end
        end
    end
    return content
end
push!(ADMIN_ROUTES, "GET" => "/openapi.json")

"""
get_open_api: Provides the get open api operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_open_api(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/openapi.json"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/health")

"""
get_health: Provides the get health operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_health(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/health"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/ready")

"""
get_readiness: Provides the get readiness operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_readiness(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/ready"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/metrics")

"""
get_metrics: Provides the get metrics operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_metrics(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/metrics"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/auth/check")

"""
check_authentication: Provides the check authentication operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function check_authentication(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/auth/check"; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/session")

"""
create_session: Provides the create session operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function create_session(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "POST", "/api/session"; query = query, body = body)
end
push!(ADMIN_ROUTES, "DELETE" => "/api/session")

"""
delete_session: Provides the delete session operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function delete_session(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "DELETE", "/api/session"; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/identity/accept-invite")

"""
accept_member_invite: Provides the accept member invite operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function accept_member_invite(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "POST", "/api/identity/accept-invite"; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/identity/mfa")

"""
begin_member_mfa: Provides the begin member mfa operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function begin_member_mfa(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "POST", "/api/identity/mfa"; query = query, body = body)
end
push!(ADMIN_ROUTES, "PUT" => "/api/identity/mfa")

"""
confirm_member_mfa: Provides the confirm member mfa operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function confirm_member_mfa(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "PUT", "/api/identity/mfa"; query = query, body = body)
end
push!(ADMIN_ROUTES, "DELETE" => "/api/identity/mfa")

"""
disable_member_mfa: Provides the disable member mfa operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function disable_member_mfa(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "DELETE", "/api/identity/mfa"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/overview")

"""
get_overview: Provides the get overview operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_overview(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/overview"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/organization")

"""
get_organization: Provides the get organization operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_organization(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/organization"; query = query, body = body)
end
push!(ADMIN_ROUTES, "PUT" => "/api/organization")

"""
update_organization: Provides the update organization operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function update_organization(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "PUT", "/api/organization"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/members")

"""
list_members: Provides the list members operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function list_members(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/members"; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/members")

"""
create_member: Provides the create member operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function create_member(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "POST", "/api/members"; query = query, body = body)
end
push!(ADMIN_ROUTES, "PATCH" => "/api/members/{id}")

"""
update_member: Provides the update member operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function update_member(
    a::AdminClient, id::AbstractString; query = Dict{String,Any}(), body = nothing
)
    p = "/api/members/{id}"
    p = replace(p, "{id}" => _pct_encode(id))
    return admin_request(a, "PATCH", p; query = query, body = body)
end
push!(ADMIN_ROUTES, "DELETE" => "/api/members/{id}")

"""
delete_member: Provides the delete member operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function delete_member(
    a::AdminClient, id::AbstractString; query = Dict{String,Any}(), body = nothing
)
    p = "/api/members/{id}"
    p = replace(p, "{id}" => _pct_encode(id))
    return admin_request(a, "DELETE", p; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/members/{id}/invite")

"""
create_member_invite: Provides the create member invite operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function create_member_invite(
    a::AdminClient, id::AbstractString; query = Dict{String,Any}(), body = nothing
)
    p = "/api/members/{id}/invite"
    p = replace(p, "{id}" => _pct_encode(id))
    return admin_request(a, "POST", p; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/rbac")

"""
get_rbac: Provides the get rbac operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_rbac(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/rbac"; query = query, body = body)
end
push!(ADMIN_ROUTES, "PUT" => "/api/rbac")

"""
update_rbac: Provides the update rbac operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function update_rbac(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "PUT", "/api/rbac"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/api-keys")

"""
list_apikeys: Provides the list apikeys operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function list_apikeys(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/api-keys"; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/api-keys")

"""
create_apikey: Provides the create apikey operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function create_apikey(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "POST", "/api/api-keys"; query = query, body = body)
end
push!(ADMIN_ROUTES, "DELETE" => "/api/api-keys/{id}")

"""
revoke_apikey: Provides the revoke apikey operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function revoke_apikey(
    a::AdminClient, id::AbstractString; query = Dict{String,Any}(), body = nothing
)
    p = "/api/api-keys/{id}"
    p = replace(p, "{id}" => _pct_encode(id))
    return admin_request(a, "DELETE", p; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/system")

"""
get_system_configuration: Provides the get system configuration operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_system_configuration(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/system"; query = query, body = body)
end
push!(ADMIN_ROUTES, "PUT" => "/api/system")

"""
update_system_configuration: Provides the update system configuration operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function update_system_configuration(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "PUT", "/api/system"; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/persistence/checkpoint")

"""
create_persistence_checkpoint: Provides the create persistence checkpoint operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function create_persistence_checkpoint(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "POST", "/api/persistence/checkpoint"; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/persistence/compact")

"""
compact_persistence: Provides the compact persistence operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function compact_persistence(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "POST", "/api/persistence/compact"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/data/keys")

"""
list_data_keys: Provides the list data keys operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function list_data_keys(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/data/keys"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/data/key")

"""
get_data_key: Provides the get data key operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function get_data_key(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/data/key"; query = query, body = body)
end
push!(ADMIN_ROUTES, "DELETE" => "/api/data/key")

"""
delete_data_key: Provides the delete data key operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function delete_data_key(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "DELETE", "/api/data/key"; query = query, body = body)
end
push!(ADMIN_ROUTES, "POST" => "/api/data/command")

"""
execute_data_command: Provides the execute data command operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function execute_data_command(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "POST", "/api/data/command"; query = query, body = body)
end
push!(ADMIN_ROUTES, "GET" => "/api/audit")

"""
list_audit_events: Provides the list audit events operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function list_audit_events(a::AdminClient; query = Dict{String,Any}(), body = nothing)
    return admin_request(a, "GET", "/api/audit"; query = query, body = body)
end
