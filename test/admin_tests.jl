# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

include("mock_admin.jl")

@testset "All 33 administration routes and cookies" begin
    m = mock_admin()
    a = AdminClient("http://127.0.0.1:$(m.port)"; bearer_token = "test-token")

    try
        result = Amaquet.get_open_api(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/openapi.json"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.get_health(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/health"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.get_readiness(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/ready"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.get_metrics(a)
        @test result isa String

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/metrics"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.check_authentication(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/auth/check"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.create_session(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/session"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.delete_session(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "DELETE"
        @test path == "/api/session"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.accept_member_invite(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/identity/accept-invite"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.begin_member_mfa(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/identity/mfa"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.confirm_member_mfa(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "PUT"
        @test path == "/api/identity/mfa"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.disable_member_mfa(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "DELETE"
        @test path == "/api/identity/mfa"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.get_overview(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/overview"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.get_organization(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/organization"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.update_organization(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "PUT"
        @test path == "/api/organization"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.list_members(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/members"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.create_member(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/members"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.update_member(a, "id with /")
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "PATCH"
        @test path == "/api/members/id%20with%20%2F"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.delete_member(a, "id with /")
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "DELETE"
        @test path == "/api/members/id%20with%20%2F"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.create_member_invite(a, "id with /")
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/members/id%20with%20%2F/invite"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.get_rbac(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/rbac"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.update_rbac(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "PUT"
        @test path == "/api/rbac"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.list_apikeys(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/api-keys"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.create_apikey(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/api-keys"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.revoke_apikey(a, "id with /")
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "DELETE"
        @test path == "/api/api-keys/id%20with%20%2F"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.get_system_configuration(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/system"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.update_system_configuration(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "PUT"
        @test path == "/api/system"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.create_persistence_checkpoint(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/persistence/checkpoint"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.compact_persistence(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/persistence/compact"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.list_data_keys(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/data/keys"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.get_data_key(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/data/key"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.delete_data_key(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "DELETE"
        @test path == "/api/data/key"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.execute_data_command(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "POST"
        @test path == "/api/data/command"
        @test headers["authorization"] == "Bearer test-token"

        result = Amaquet.list_audit_events(a)
        @test result["ok"] === true

        method, path, headers, body = take!(m.requests)
        @test method == "GET"
        @test path == "/api/audit"
        @test headers["authorization"] == "Bearer test-token"
        @test a.session_cookie == "mock-session"
    finally
        stop_mock!(m)
    end
end
