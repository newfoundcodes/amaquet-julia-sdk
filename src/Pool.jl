# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

"""
ConnectionPool: Provides the Connection Pool operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Reuses native connections with bounded concurrency and explicit close or replacement behavior.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
mutable struct ConnectionPool
    uri::String
    options::NamedTuple
    limit::Int
    idle::Vector{NativeClient}
    opened::Int
    lock::ReentrantLock
    closed::Bool
end

"""
ConnectionPool: Provides the Connection Pool operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `uri`: Native Amaquet URI. Use amaquets:// for TLS.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function ConnectionPool(uri::AbstractString; size::Int = 4, kwargs...)
    1 <= size <= 256 || throw(ArgumentError("pool size must be 1..256"))

    return ConnectionPool(
        String(uri), (; kwargs...), size, NativeClient[], 0, ReentrantLock(), false
    )
end

"""
checkout: Provides the checkout operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `timeout`: Time budget for the request; timeout does not guarantee server-side cancellation.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function checkout(pool::ConnectionPool; timeout::Real = 10)
    timeout > 0 || throw(ArgumentError("timeout must be positive"))
    should_connect = Ref(false)
    client = Ref{Union{NativeClient,Nothing}}(nothing)

    """
    attempt: Provides the attempt operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
    Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    function attempt()
        lock(pool.lock) do
            pool.closed && throw(ClientClosedError("pool closed"))
            while !isempty(pool.idle)
                c = pop!(pool.idle)
                if c.isclosed
                    pool.opened -= 1
                else
                    client[] = c
                    return true
                end
            end

            if pool.opened < pool.limit
                pool.opened += 1
                should_connect[] = true
                return true
            end
        end
        return false
    end

    """
    timedwait: Provides the timedwait operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
    Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
    Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
    """
    timedwait(attempt, timeout; pollint = 0.005) == :ok ||
        throw(ProtocolError("pool checkout timeout"))
    if should_connect[]
        try
            return connect(pool.uri; pool.options...)
        catch
            lock(pool.lock) do
                return pool.opened -= 1
            end
            rethrow()
        end
    end
    return client[]::NativeClient
end

"""
release!: Provides the release! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function release!(pool::ConnectionPool, c::NativeClient)
    reuse = lock(c.state_lock) do
        return !c.isclosed && isempty(c.pending) && isempty(c.subscriptions)
    end

    lock(pool.lock) do
        if pool.closed || !reuse
            close!(c)
            pool.opened -= 1
        else
            push!(pool.idle, c)
        end
    end
    return nothing
end

"""
with_client: Provides the with client operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Parameter `timeout`: Time budget for the request; timeout does not guarantee server-side cancellation.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function with_client(f::Function, pool::ConnectionPool; timeout = 10)
    c = checkout(pool; timeout = timeout)
    try
        f(c)
    finally
        release!(pool, c)
    end
end

"""
close!: Release network resources and notify waiting operations of connection shutdown.
Use TLS and identity pins for remote endpoints; close resources and bound pending requests in long-running applications.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function close!(pool::ConnectionPool)
    lock(pool.lock) do
        pool.closed = true

        foreach(close!, pool.idle)
        pool.opened -= length(pool.idle)

        return empty!(pool.idle)
    end
    return nothing
end
