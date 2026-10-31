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

mutable struct MockAdmin
    listener::Sockets.TCPServer
    task::Task
    requests::Channel{Any}
    port::Int
end

function mock_admin()
    listener = Sockets.listen(ip"127.0.0.1", 0)
    _, port = Sockets.getsockname(listener)

    events = Channel{Any}(128)
    task = @async begin
        while isopen(listener)
            s = try
                Sockets.accept(listener)
            catch
                break
            end

            @async begin
                try
                    firstline = strip(readline(s))
                    fields = split(firstline)
                    length(fields) >= 2 || return nothing

                    method, path = fields[1:2]
                    headers = Dict{String,String}()

                    while true
                        line = strip(readline(s))
                        isempty(line) && break
                        pair = split(line, ':'; limit = 2)
                        length(pair) == 2 && (headers[lowercase(strip(pair[1]))] = strip(pair[2]))
                    end

                    n = parse(Int, get(headers, "content-length", "0"))
                    body = n > 0 ? read(s, n) : UInt8[]
                    put!(events, (method, path, headers, String(body)))

                    metrics = startswith(path, "/metrics")
                    unauthorized = startswith(path, "/test-unauthorized")
                    status = unauthorized ? "401 Unauthorized" : "200 OK"

                    response = if metrics
                        "amaquet_up 1\n"
                    else
                        JSON.json(Dict("ok"=>true, "method"=>method, "path"=>path))
                    end

                    ctype = metrics ? "text/plain" : "application/json"
                    cookie = if path == "/api/session" && method == "POST"
                        "Set-Cookie: amaquet_session=mock-session; HttpOnly; SameSite=Strict\r\n"
                    else
                        ""
                    end

                    write(
                        s,
                        "HTTP/1.1 $status\r\nContent-Type: $ctype\r\nContent-Length: $(ncodeunits(response))\r\nConnection: close\r\n"*cookie*"\r\n"*response,
                    )
                    flush(s)
                catch e
                    @warn "mock admin connection error" exception=(e, catch_backtrace())
                finally
                    try
                        close(s)
                    catch
                    end
                end
            end
        end
    end

    return MockAdmin(listener, task, events, port)
end

function stop_mock!(m::MockAdmin)
    try
        close(m.listener)
    catch
    end
    try
        close(m.requests)
    catch
    end
end
