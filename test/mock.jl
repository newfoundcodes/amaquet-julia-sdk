# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

using Sockets: Sockets
using Sockets: @ip_str
using JSON

"""
A deterministic native protocol test server. Not a substitute for a live Amaquet server.
"""
mutable struct MockNative
    listener::Sockets.TCPServer
    task::Task
    requests::Channel{Any}
    port::Int
end

function mock_native(; reverse_pair = false)
    listener = Sockets.listen(ip"127.0.0.1", 0)
    _, port = Sockets.getsockname(listener)

    requests = Channel{Any}(1024)
    task = @async begin
        socket = Sockets.accept(listener)
        deferred = nothing

        try
            while isopen(socket)
                f = Amaquet.decode_frame(socket)
                payload = JSON.parse(String(f.payload))
                put!(requests, (f.opcode, payload))

                result = if f.opcode == 2
                    Dict("name"=>"Amaquet", "selected_protocol"=>1, "auth_required"=>false)
                elseif f.opcode == 3
                    Dict("authenticated"=>true, "role"=>"developer")
                elseif f.opcode == 4
                    Dict("subscribed"=>true)
                elseif f.opcode == 5
                    Dict("unsubscribed"=>true)
                elseif f.opcode == 6
                    Dict("cancelled"=>true)
                elseif get(payload, "command", "") == "TYPES"
                    collect(keys(Amaquet.TYPE_CATALOG))
                elseif get(payload, "command", "") == "PING"
                    "PONG"
                elseif get(payload, "command", "") == "BLOB_READ"
                    Dict(
                        "offset"=>get(payload["args"], "offset", 0),
                        "size"=>0,
                        "version"=>1,
                        "data"=>"",
                    )
                else
                    payload
                end

                response = Amaquet.Frame(
                    2,
                    1,
                    f.request_id,
                    Vector{UInt8}(codeunits(JSON.json(Dict("ok"=>true, "result"=>result)))),
                )

                if reverse_pair && f.opcode == 1 && get(payload, "command", "") == "PING"
                    if deferred === nothing
                        deferred = response
                        continue
                    else
                        write(socket, Amaquet.encode_frame(response))
                        write(socket, Amaquet.encode_frame(deferred))
                        flush(socket)

                        deferred = nothing
                        continue
                    end
                end

                write(socket, Amaquet.encode_frame(response))
                flush(socket)
            end
        catch e
            # Expected EOF when test client closes.
            if !(e isa EOFError || e isa Base.IOError || e isa Amaquet.ClientClosedError)
                @warn "mock server closed" exception=(e, catch_backtrace())
            end
        finally
            try
                close(socket)
            catch
            end
        end
    end
    return MockNative(listener, task, requests, port)
end

function stop_mock!(m::MockNative)
    try
        close(m.listener)
    catch
    end

    try
        close(m.requests)
    catch
    end
end
