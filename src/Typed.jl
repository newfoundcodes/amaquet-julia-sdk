# Amaquet Julia SDK - A Newfoundcodes project.
#
# Copyright (C) 2026 Jonathan Eldy Baldivicio
#
# Author: Jonathan Eldy Baldivicio
# Contact: jonathaneldy.baldivicio@newfoundcodes.com
#
# SPDX-License-Identifier: MIT

abstract type AbstractTypeHandle end

"""
GenericTypeHandle: Provides the Generic Type Handle operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Provides per-key type handles and dispatch helpers for Amaquet OP commands.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct GenericTypeHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
typehandle: Provides the typehandle operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function typehandle(c::NativeClient, wiretype::AbstractString, key::AbstractString)
    haskey(TYPE_CATALOG, String(wiretype)) || throw(ArgumentError("unknown wire type"))
    return typed_handle(c, String(wiretype), String(key))
end

"""
typed: Provides the typed operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
typed(c::NativeClient, typ::AbstractString, key::AbstractString) = typehandle(c, typ, key)
"""
typed: Provides the typed operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Parameter `name`: Native command or type operation name sent to the server.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
typed(c::NativeClient) = (name, key) -> typehandle(c, name, key)
"""
snapshot: Read the server snapshot of the current key; returned JSON shape depends on the stored wire type.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
snapshot(h::AbstractTypeHandle) = get(h.client, h.key)
"""
delete!: Provides the delete! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
delete!(h::AbstractTypeHandle) = delete!(h.client, h.key)
"""
create!: Provides the create! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `options`: Call settings or documented construction flags, as accepted by this method.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function create!(h::AbstractTypeHandle; options = Dict{String,Any}(), kwargs...)
    return create!(h.client, h.key, h.wire_type; options = options, kwargs...)
end

"""
set!: Provides the set! operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
set!(h::AbstractTypeHandle, value; kwargs...) = set!(h.client, h.key, h.wire_type, value; kwargs...)
"""
operation: Dispatch a typed OP command using the key, exact uppercase operation name, and server-defined argument map.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
Parameter `name`: Native command or type operation name sent to the server.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function operation(h::AbstractTypeHandle, name::AbstractString, args = Dict{String,Any}())
    return operation(h.client, h.key, name, args)
end

"""
AdjacencySetHandle: typed facade for the registered `adjacency_set` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `NEIGHBORS`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct AdjacencySetHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
AdjacencySetHandle: send native OP ADD to the existing `adjacency_set` key.
The server applies `adjacency_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`, `weight`.
Reference argument example: {"from":"a","to":"b","weight":1.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function AdjacencySetHandle(c::NativeClient, key::AbstractString)
    return AdjacencySetHandle(c, String(key), "adjacency_set")
end

"""
adjacency_set: send native OP ADD to the existing `adjacency_set` key.
The server applies `adjacency_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`, `weight`.
Reference argument example: {"from":"a","to":"b","weight":1.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
adjacency_set(c::NativeClient, key::AbstractString) = AdjacencySetHandle(c, key)

"""
op_add: send native OP ADD to the existing `adjacency_set` key.
The server applies `adjacency_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`, `weight`.
Reference argument example: {"from":"a","to":"b","weight":1.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::AdjacencySetHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_neighbors: send native OP NEIGHBORS to the existing `adjacency_set` key.
The server applies `adjacency_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`.
Reference argument example: {"from":"a"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_neighbors(h::AdjacencySetHandle, args = Dict{String,Any}()) = operation(h, "NEIGHBORS", args)

"""
op_remove: send native OP REMOVE to the existing `adjacency_set` key.
The server applies `adjacency_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`.
Reference argument example: {"from":"a","to":"b"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::AdjacencySetHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
AggregatedSeriesHandle: typed facade for the registered `aggregated_series` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `bucket_ms`, `aggregation`.
Supported named operations: `AGGREGATE`, `RANGE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct AggregatedSeriesHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
AggregatedSeriesHandle: send native OP AGGREGATE to the existing `aggregated_series` key.
The server applies `aggregated_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `source_key`, `from`, `to`, `bucket_ms`, `aggregation`.
Reference argument example: {"source_key":"example:timeseries:source","from":0,"to":3000,"bucket_ms":1000,"aggregation":"avg"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function AggregatedSeriesHandle(c::NativeClient, key::AbstractString)
    return AggregatedSeriesHandle(c, String(key), "aggregated_series")
end

"""
aggregated_series: send native OP AGGREGATE to the existing `aggregated_series` key.
The server applies `aggregated_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `source_key`, `from`, `to`, `bucket_ms`, `aggregation`.
Reference argument example: {"source_key":"example:timeseries:source","from":0,"to":3000,"bucket_ms":1000,"aggregation":"avg"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
aggregated_series(c::NativeClient, key::AbstractString) = AggregatedSeriesHandle(c, key)

"""
op_aggregate: send native OP AGGREGATE to the existing `aggregated_series` key.
The server applies `aggregated_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `source_key`, `from`, `to`, `bucket_ms`, `aggregation`.
Reference argument example: {"source_key":"example:timeseries:source","from":0,"to":3000,"bucket_ms":1000,"aggregation":"avg"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_aggregate(h::AggregatedSeriesHandle, args = Dict{String,Any}()) = operation(h, "AGGREGATE", args)

"""
op_range: send native OP RANGE to the existing `aggregated_series` key.
The server applies `aggregated_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `source_key`, `from`, `to`, `bucket_ms`, `aggregation`.
Reference argument example: {"source_key":"example:timeseries:source","from":0,"to":3000,"bucket_ms":1000,"aggregation":"avg"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_range(h::AggregatedSeriesHandle, args = Dict{String,Any}()) = operation(h, "RANGE", args)

"""
ArrayHandle: typed facade for the registered `array` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `typed`, `element_type`.
Supported named operations: `APPEND`, `GET`, `LEN`, `SET`, `VALUES`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct ArrayHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
ArrayHandle: send native OP APPEND to the existing `array` key.
The server applies `array` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
ArrayHandle(c::NativeClient, key::AbstractString) = ArrayHandle(c, String(key), "array")

"""
array: send native OP APPEND to the existing `array` key.
The server applies `array` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
array(c::NativeClient, key::AbstractString) = ArrayHandle(c, key)

"""
op_append: send native OP APPEND to the existing `array` key.
The server applies `array` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_append(h::ArrayHandle, args = Dict{String,Any}()) = operation(h, "APPEND", args)

"""
op_get: send native OP GET to the existing `array` key.
The server applies `array` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `index`.
Reference argument example: {"index":0}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::ArrayHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
op_len: send native OP LEN to the existing `array` key.
The server applies `array` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::ArrayHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_set: send native OP SET to the existing `array` key.
The server applies `array` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `index`, `value`.
Reference argument example: {"index":0,"value":{"type":"utf8_string","value":"updated"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::ArrayHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_values: send native OP VALUES to the existing `array` key.
The server applies `array` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_values(h::ArrayHandle, args = Dict{String,Any}()) = operation(h, "VALUES", args)

"""
AtomicCounterHandle: typed facade for the registered `atomic_counter` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `initial`.
Supported named operations: `ADD`, `CAS`, `LOAD`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct AtomicCounterHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
AtomicCounterHandle: send native OP ADD to the existing `atomic_counter` key.
The server applies `atomic_counter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function AtomicCounterHandle(c::NativeClient, key::AbstractString)
    return AtomicCounterHandle(c, String(key), "atomic_counter")
end

"""
atomic_counter: send native OP ADD to the existing `atomic_counter` key.
The server applies `atomic_counter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
atomic_counter(c::NativeClient, key::AbstractString) = AtomicCounterHandle(c, key)

"""
op_add: send native OP ADD to the existing `atomic_counter` key.
The server applies `atomic_counter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::AtomicCounterHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_cas: send native OP CAS to the existing `atomic_counter` key.
The server applies `atomic_counter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `old`, `new`.
Reference argument example: {"old":15,"new":20}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_cas(h::AtomicCounterHandle, args = Dict{String,Any}()) = operation(h, "CAS", args)

"""
op_load: send native OP LOAD to the existing `atomic_counter` key.
The server applies `atomic_counter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_load(h::AtomicCounterHandle, args = Dict{String,Any}()) = operation(h, "LOAD", args)

"""
BarrierHandle: typed facade for the registered `barrier` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `target`.
Supported named operations: `WAIT`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BarrierHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BarrierHandle: send native OP WAIT to the existing `barrier` key.
The server applies `barrier` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
BarrierHandle(c::NativeClient, key::AbstractString) = BarrierHandle(c, String(key), "barrier")

"""
barrier: send native OP WAIT to the existing `barrier` key.
The server applies `barrier` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
barrier(c::NativeClient, key::AbstractString) = BarrierHandle(c, key)

"""
op_wait: send native OP WAIT to the existing `barrier` key.
The server applies `barrier` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_wait(h::BarrierHandle, args = Dict{String,Any}()) = operation(h, "WAIT", args)

"""
BigDecimalHandle: typed facade for the registered `big_decimal` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `ADD`, `CMP`, `SUB`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BigDecimalHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BigDecimalHandle: send native OP ADD to the existing `big_decimal` key.
The server applies `big_decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"0.3211"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function BigDecimalHandle(c::NativeClient, key::AbstractString)
    return BigDecimalHandle(c, String(key), "big_decimal")
end

"""
big_decimal: send native OP ADD to the existing `big_decimal` key.
The server applies `big_decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"0.3211"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
big_decimal(c::NativeClient, key::AbstractString) = BigDecimalHandle(c, key)

"""
op_add: send native OP ADD to the existing `big_decimal` key.
The server applies `big_decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"0.3211"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::BigDecimalHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_cmp: send native OP CMP to the existing `big_decimal` key.
The server applies `big_decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"12345678901234567890.321100000000000001"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_cmp(h::BigDecimalHandle, args = Dict{String,Any}()) = operation(h, "CMP", args)

"""
op_sub: send native OP SUB to the existing `big_decimal` key.
The server applies `big_decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"0.0011"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_sub(h::BigDecimalHandle, args = Dict{String,Any}()) = operation(h, "SUB", args)

"""
BigIntegerHandle: typed facade for the registered `big_integer` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `ADD`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BigIntegerHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BigIntegerHandle: send native OP ADD to the existing `big_integer` key.
The server applies `big_integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"10"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function BigIntegerHandle(c::NativeClient, key::AbstractString)
    return BigIntegerHandle(c, String(key), "big_integer")
end

"""
big_integer: send native OP ADD to the existing `big_integer` key.
The server applies `big_integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"10"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
big_integer(c::NativeClient, key::AbstractString) = BigIntegerHandle(c, key)

"""
op_add: send native OP ADD to the existing `big_integer` key.
The server applies `big_integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"10"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::BigIntegerHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
BinaryStringHandle: typed facade for the registered `binary_string` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BinaryStringHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BinaryStringHandle: typed facade for the registered `binary_string` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function BinaryStringHandle(c::NativeClient, key::AbstractString)
    return BinaryStringHandle(c, String(key), "binary_string")
end

"""
binary_string: Provides the binary string operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
binary_string(c::NativeClient, key::AbstractString) = BinaryStringHandle(c, key)

"""
BitFieldHandle: typed facade for the registered `bit_field` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `size_bytes`.
Supported named operations: `SET`, `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BitFieldHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BitFieldHandle: send native OP SET to the existing `bit_field` key.
The server applies `bit_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `offset`, `width`, `value`.
Reference argument example: {"offset":4,"width":8,"value":171}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
BitFieldHandle(c::NativeClient, key::AbstractString) = BitFieldHandle(c, String(key), "bit_field")

"""
bit_field: send native OP SET to the existing `bit_field` key.
The server applies `bit_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `offset`, `width`, `value`.
Reference argument example: {"offset":4,"width":8,"value":171}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
bit_field(c::NativeClient, key::AbstractString) = BitFieldHandle(c, key)

"""
op_set: send native OP SET to the existing `bit_field` key.
The server applies `bit_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `offset`, `width`, `value`.
Reference argument example: {"offset":4,"width":8,"value":171}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::BitFieldHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `bit_field` key.
The server applies `bit_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `offset`, `width`.
Reference argument example: {"offset":4,"width":8}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::BitFieldHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
BitSetHandle: typed facade for the registered `bit_set` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `SET`, `GETBIT`, `COUNT`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BitSetHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BitSetHandle: send native OP SET to the existing `bit_set` key.
The server applies `bit_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `bit`, `value`.
Reference argument example: {"bit":7,"value":true}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
BitSetHandle(c::NativeClient, key::AbstractString) = BitSetHandle(c, String(key), "bit_set")

"""
bit_set: send native OP SET to the existing `bit_set` key.
The server applies `bit_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `bit`, `value`.
Reference argument example: {"bit":7,"value":true}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
bit_set(c::NativeClient, key::AbstractString) = BitSetHandle(c, key)

"""
op_set: send native OP SET to the existing `bit_set` key.
The server applies `bit_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `bit`, `value`.
Reference argument example: {"bit":7,"value":true}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::BitSetHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_getbit: send native OP GETBIT to the existing `bit_set` key.
The server applies `bit_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `bit`.
Reference argument example: {"bit":7}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_getbit(h::BitSetHandle, args = Dict{String,Any}()) = operation(h, "GETBIT", args)

"""
op_count: send native OP COUNT to the existing `bit_set` key.
The server applies `bit_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_count(h::BitSetHandle, args = Dict{String,Any}()) = operation(h, "COUNT", args)

"""
BitmapHandle: typed facade for the registered `bitmap` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `SET`, `GETBIT`, `COUNT`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BitmapHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BitmapHandle: send native OP SET to the existing `bitmap` key.
The server applies `bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `bit`, `value`.
Reference argument example: {"bit":7,"value":true}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
BitmapHandle(c::NativeClient, key::AbstractString) = BitmapHandle(c, String(key), "bitmap")

"""
bitmap: send native OP SET to the existing `bitmap` key.
The server applies `bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `bit`, `value`.
Reference argument example: {"bit":7,"value":true}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
bitmap(c::NativeClient, key::AbstractString) = BitmapHandle(c, key)

"""
op_set: send native OP SET to the existing `bitmap` key.
The server applies `bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `bit`, `value`.
Reference argument example: {"bit":7,"value":true}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::BitmapHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_getbit: send native OP GETBIT to the existing `bitmap` key.
The server applies `bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `bit`.
Reference argument example: {"bit":7}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_getbit(h::BitmapHandle, args = Dict{String,Any}()) = operation(h, "GETBIT", args)

"""
op_count: send native OP COUNT to the existing `bitmap` key.
The server applies `bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_count(h::BitmapHandle, args = Dict{String,Any}()) = operation(h, "COUNT", args)

"""
BlockingQueueHandle: typed facade for the registered `blocking_queue` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ENQUEUE`, `DEQUEUE`, `CLOSE`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BlockingQueueHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BlockingQueueHandle: send native OP ENQUEUE to the existing `blocking_queue` key.
The server applies `blocking_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function BlockingQueueHandle(c::NativeClient, key::AbstractString)
    return BlockingQueueHandle(c, String(key), "blocking_queue")
end

"""
blocking_queue: send native OP ENQUEUE to the existing `blocking_queue` key.
The server applies `blocking_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
blocking_queue(c::NativeClient, key::AbstractString) = BlockingQueueHandle(c, key)

"""
op_enqueue: send native OP ENQUEUE to the existing `blocking_queue` key.
The server applies `blocking_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_enqueue(h::BlockingQueueHandle, args = Dict{String,Any}()) = operation(h, "ENQUEUE", args)

"""
op_dequeue: send native OP DEQUEUE to the existing `blocking_queue` key.
The server applies `blocking_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_dequeue(h::BlockingQueueHandle, args = Dict{String,Any}()) = operation(h, "DEQUEUE", args)

"""
op_close: send native OP CLOSE to the existing `blocking_queue` key.
The server applies `blocking_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_close(h::BlockingQueueHandle, args = Dict{String,Any}()) = operation(h, "CLOSE", args)

"""
op_len: send native OP LEN to the existing `blocking_queue` key.
The server applies `blocking_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::BlockingQueueHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
BloomFilterHandle: typed facade for the registered `bloom_filter` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `expected`, `false_positive_rate`.
Supported named operations: `ADD`, `CONTAINS`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BloomFilterHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BloomFilterHandle: send native OP ADD to the existing `bloom_filter` key.
The server applies `bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function BloomFilterHandle(c::NativeClient, key::AbstractString)
    return BloomFilterHandle(c, String(key), "bloom_filter")
end

"""
bloom_filter: send native OP ADD to the existing `bloom_filter` key.
The server applies `bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
bloom_filter(c::NativeClient, key::AbstractString) = BloomFilterHandle(c, key)

"""
op_add: send native OP ADD to the existing `bloom_filter` key.
The server applies `bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::BloomFilterHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_contains: send native OP CONTAINS to the existing `bloom_filter` key.
The server applies `bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_contains(h::BloomFilterHandle, args = Dict{String,Any}()) = operation(h, "CONTAINS", args)

"""
BooleanHandle: typed facade for the registered `boolean` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `TOGGLE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BooleanHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BooleanHandle: send native OP TOGGLE to the existing `boolean` key.
The server applies `boolean` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
BooleanHandle(c::NativeClient, key::AbstractString) = BooleanHandle(c, String(key), "boolean")

"""
boolean: send native OP TOGGLE to the existing `boolean` key.
The server applies `boolean` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
boolean(c::NativeClient, key::AbstractString) = BooleanHandle(c, key)

"""
op_toggle: send native OP TOGGLE to the existing `boolean` key.
The server applies `boolean` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_toggle(h::BooleanHandle, args = Dict{String,Any}()) = operation(h, "TOGGLE", args)

"""
BoundingBoxHandle: typed facade for the registered `bounding_box` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `CONTAINS`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BoundingBoxHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BoundingBoxHandle: send native OP CONTAINS to the existing `bounding_box` key.
The server applies `bounding_box` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.5,"Lon":121.0}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function BoundingBoxHandle(c::NativeClient, key::AbstractString)
    return BoundingBoxHandle(c, String(key), "bounding_box")
end

"""
bounding_box: send native OP CONTAINS to the existing `bounding_box` key.
The server applies `bounding_box` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.5,"Lon":121.0}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
bounding_box(c::NativeClient, key::AbstractString) = BoundingBoxHandle(c, key)

"""
op_contains: send native OP CONTAINS to the existing `bounding_box` key.
The server applies `bounding_box` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.5,"Lon":121.0}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_contains(h::BoundingBoxHandle, args = Dict{String,Any}()) = operation(h, "CONTAINS", args)

"""
BtreeIndexHandle: typed facade for the registered `btree_index` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `degree`.
Supported named operations: `INSERT`, `SEARCH`, `DELETE`, `RANGE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct BtreeIndexHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
BtreeIndexHandle: send native OP INSERT to the existing `btree_index` key.
The server applies `btree_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"b","id":"2"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function BtreeIndexHandle(c::NativeClient, key::AbstractString)
    return BtreeIndexHandle(c, String(key), "btree_index")
end

"""
btree_index: send native OP INSERT to the existing `btree_index` key.
The server applies `btree_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"b","id":"2"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
btree_index(c::NativeClient, key::AbstractString) = BtreeIndexHandle(c, key)

"""
op_insert: send native OP INSERT to the existing `btree_index` key.
The server applies `btree_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"b","id":"2"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_insert(h::BtreeIndexHandle, args = Dict{String,Any}()) = operation(h, "INSERT", args)

"""
op_search: send native OP SEARCH to the existing `btree_index` key.
The server applies `btree_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"a"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_search(h::BtreeIndexHandle, args = Dict{String,Any}()) = operation(h, "SEARCH", args)

"""
op_delete: send native OP DELETE to the existing `btree_index` key.
The server applies `btree_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"b","id":"2"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_delete(h::BtreeIndexHandle, args = Dict{String,Any}()) = operation(h, "DELETE", args)

"""
op_range: send native OP RANGE to the existing `btree_index` key.
The server applies `btree_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `max`, `limit`.
Reference argument example: {"value":"a","max":"z","limit":10}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_range(h::BtreeIndexHandle, args = Dict{String,Any}()) = operation(h, "RANGE", args)

"""
CborHandle: typed facade for the registered `cbor` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct CborHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
CborHandle: send native OP GET to the existing `cbor` key.
The server applies `cbor` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
CborHandle(c::NativeClient, key::AbstractString) = CborHandle(c, String(key), "cbor")

"""
cbor: send native OP GET to the existing `cbor` key.
The server applies `cbor` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
cbor(c::NativeClient, key::AbstractString) = CborHandle(c, key)

"""
op_get: send native OP GET to the existing `cbor` key.
The server applies `cbor` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::CborHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
CidrNetworkHandle: typed facade for the registered `cidr_network` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `CONTAINS`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct CidrNetworkHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
CidrNetworkHandle: send native OP CONTAINS to the existing `cidr_network` key.
The server applies `cidr_network` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `ip`.
Reference argument example: {"ip":"10.1.2.3"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function CidrNetworkHandle(c::NativeClient, key::AbstractString)
    return CidrNetworkHandle(c, String(key), "cidr_network")
end

"""
cidr_network: send native OP CONTAINS to the existing `cidr_network` key.
The server applies `cidr_network` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `ip`.
Reference argument example: {"ip":"10.1.2.3"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
cidr_network(c::NativeClient, key::AbstractString) = CidrNetworkHandle(c, key)

"""
op_contains: send native OP CONTAINS to the existing `cidr_network` key.
The server applies `cidr_network` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `ip`.
Reference argument example: {"ip":"10.1.2.3"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_contains(h::CidrNetworkHandle, args = Dict{String,Any}()) = operation(h, "CONTAINS", args)

"""
ConsumerGroupHandle: typed facade for the registered `consumer_group` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `name`.
Supported named operations: `SNAPSHOT`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct ConsumerGroupHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
ConsumerGroupHandle: send native OP SNAPSHOT to the existing `consumer_group` key.
The server applies `consumer_group` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function ConsumerGroupHandle(c::NativeClient, key::AbstractString)
    return ConsumerGroupHandle(c, String(key), "consumer_group")
end

"""
consumer_group: send native OP SNAPSHOT to the existing `consumer_group` key.
The server applies `consumer_group` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
consumer_group(c::NativeClient, key::AbstractString) = ConsumerGroupHandle(c, key)

"""
op_snapshot: send native OP SNAPSHOT to the existing `consumer_group` key.
The server applies `consumer_group` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_snapshot(h::ConsumerGroupHandle, args = Dict{String,Any}()) = operation(h, "SNAPSHOT", args)

"""
CountMinSketchHandle: typed facade for the registered `count_min_sketch` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `width`, `depth`.
Supported named operations: `ADD`, `ESTIMATE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct CountMinSketchHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
CountMinSketchHandle: send native OP ADD to the existing `count_min_sketch` key.
The server applies `count_min_sketch` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":"alice","count":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function CountMinSketchHandle(c::NativeClient, key::AbstractString)
    return CountMinSketchHandle(c, String(key), "count_min_sketch")
end

"""
count_min_sketch: send native OP ADD to the existing `count_min_sketch` key.
The server applies `count_min_sketch` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":"alice","count":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
count_min_sketch(c::NativeClient, key::AbstractString) = CountMinSketchHandle(c, key)

"""
op_add: send native OP ADD to the existing `count_min_sketch` key.
The server applies `count_min_sketch` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":"alice","count":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::CountMinSketchHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_estimate: send native OP ESTIMATE to the existing `count_min_sketch` key.
The server applies `count_min_sketch` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_estimate(h::CountMinSketchHandle, args = Dict{String,Any}()) = operation(h, "ESTIMATE", args)

"""
CounterSeriesHandle: typed facade for the registered `counter_series` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `labels`.
Supported named operations: `ADD`, `LAST`, `AGGREGATE`, `LEN`, `RANGE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct CounterSeriesHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
CounterSeriesHandle: send native OP ADD to the existing `counter_series` key.
The server applies `counter_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1000,"value":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function CounterSeriesHandle(c::NativeClient, key::AbstractString)
    return CounterSeriesHandle(c, String(key), "counter_series")
end

"""
counter_series: send native OP ADD to the existing `counter_series` key.
The server applies `counter_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1000,"value":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
counter_series(c::NativeClient, key::AbstractString) = CounterSeriesHandle(c, key)

"""
op_add: send native OP ADD to the existing `counter_series` key.
The server applies `counter_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1000,"value":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::CounterSeriesHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_last: send native OP LAST to the existing `counter_series` key.
The server applies `counter_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_last(h::CounterSeriesHandle, args = Dict{String,Any}()) = operation(h, "LAST", args)

"""
op_aggregate: send native OP AGGREGATE to the existing `counter_series` key.
The server applies `counter_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`, `bucket_ms`, `aggregation`.
Reference argument example: {"from":0,"to":3000,"bucket_ms":1000,"aggregation":"sum"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_aggregate(h::CounterSeriesHandle, args = Dict{String,Any}()) = operation(h, "AGGREGATE", args)

"""
op_len: send native OP LEN to the existing `counter_series` key.
The server applies `counter_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::CounterSeriesHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_range: send native OP RANGE to the existing `counter_series` key.
The server applies `counter_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`.
Reference argument example: {"from":0,"to":3000}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_range(h::CounterSeriesHandle, args = Dict{String,Any}()) = operation(h, "RANGE", args)

"""
CountingBloomFilterHandle: typed facade for the registered `counting_bloom_filter` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `expected`, `false_positive_rate`.
Supported named operations: `ADD`, `CONTAINS`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct CountingBloomFilterHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
CountingBloomFilterHandle: send native OP ADD to the existing `counting_bloom_filter` key.
The server applies `counting_bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function CountingBloomFilterHandle(c::NativeClient, key::AbstractString)
    return CountingBloomFilterHandle(c, String(key), "counting_bloom_filter")
end

"""
counting_bloom_filter: send native OP ADD to the existing `counting_bloom_filter` key.
The server applies `counting_bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
counting_bloom_filter(c::NativeClient, key::AbstractString) = CountingBloomFilterHandle(c, key)

"""
op_add: send native OP ADD to the existing `counting_bloom_filter` key.
The server applies `counting_bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::CountingBloomFilterHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_contains: send native OP CONTAINS to the existing `counting_bloom_filter` key.
The server applies `counting_bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
function op_contains(h::CountingBloomFilterHandle, args = Dict{String,Any}())
    return operation(h, "CONTAINS", args)
end

"""
op_remove: send native OP REMOVE to the existing `counting_bloom_filter` key.
The server applies `counting_bloom_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::CountingBloomFilterHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
CuckooFilterHandle: typed facade for the registered `cuckoo_filter` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `capacity`.
Supported named operations: `ADD`, `CONTAINS`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct CuckooFilterHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
CuckooFilterHandle: send native OP ADD to the existing `cuckoo_filter` key.
The server applies `cuckoo_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function CuckooFilterHandle(c::NativeClient, key::AbstractString)
    return CuckooFilterHandle(c, String(key), "cuckoo_filter")
end

"""
cuckoo_filter: send native OP ADD to the existing `cuckoo_filter` key.
The server applies `cuckoo_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
cuckoo_filter(c::NativeClient, key::AbstractString) = CuckooFilterHandle(c, key)

"""
op_add: send native OP ADD to the existing `cuckoo_filter` key.
The server applies `cuckoo_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::CuckooFilterHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_contains: send native OP CONTAINS to the existing `cuckoo_filter` key.
The server applies `cuckoo_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_contains(h::CuckooFilterHandle, args = Dict{String,Any}()) = operation(h, "CONTAINS", args)

"""
op_remove: send native OP REMOVE to the existing `cuckoo_filter` key.
The server applies `cuckoo_filter` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::CuckooFilterHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
DecimalHandle: typed facade for the registered `decimal` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `ADD`, `CMP`, `SUB`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct DecimalHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
DecimalHandle: send native OP ADD to the existing `decimal` key.
The server applies `decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"0.3211"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
DecimalHandle(c::NativeClient, key::AbstractString) = DecimalHandle(c, String(key), "decimal")

"""
decimal: send native OP ADD to the existing `decimal` key.
The server applies `decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"0.3211"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
decimal(c::NativeClient, key::AbstractString) = DecimalHandle(c, key)

"""
op_add: send native OP ADD to the existing `decimal` key.
The server applies `decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"0.3211"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::DecimalHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_cmp: send native OP CMP to the existing `decimal` key.
The server applies `decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"12346.0000"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_cmp(h::DecimalHandle, args = Dict{String,Any}()) = operation(h, "CMP", args)

"""
op_sub: send native OP SUB to the existing `decimal` key.
The server applies `decimal` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"0.3211"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_sub(h::DecimalHandle, args = Dict{String,Any}()) = operation(h, "SUB", args)

"""
DelayedQueueHandle: typed facade for the registered `delayed_queue` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ENQUEUE`, `POP_READY`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct DelayedQueueHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
DelayedQueueHandle: send native OP ENQUEUE to the existing `delayed_queue` key.
The server applies `delayed_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `value`, `available_at_ms`.
Reference argument example: {"id":"job1","value":{"type":"utf8_string","value":"payload"},"available_at_ms":0}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function DelayedQueueHandle(c::NativeClient, key::AbstractString)
    return DelayedQueueHandle(c, String(key), "delayed_queue")
end

"""
delayed_queue: send native OP ENQUEUE to the existing `delayed_queue` key.
The server applies `delayed_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `value`, `available_at_ms`.
Reference argument example: {"id":"job1","value":{"type":"utf8_string","value":"payload"},"available_at_ms":0}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
delayed_queue(c::NativeClient, key::AbstractString) = DelayedQueueHandle(c, key)

"""
op_enqueue: send native OP ENQUEUE to the existing `delayed_queue` key.
The server applies `delayed_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `value`, `available_at_ms`.
Reference argument example: {"id":"job1","value":{"type":"utf8_string","value":"payload"},"available_at_ms":0}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_enqueue(h::DelayedQueueHandle, args = Dict{String,Any}()) = operation(h, "ENQUEUE", args)

"""
op_pop_ready: send native OP POP_READY to the existing `delayed_queue` key.
The server applies `delayed_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_pop_ready(h::DelayedQueueHandle, args = Dict{String,Any}()) = operation(h, "POP_READY", args)

"""
op_len: send native OP LEN to the existing `delayed_queue` key.
The server applies `delayed_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::DelayedQueueHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
DenseVectorHandle: typed facade for the registered `dense_vector` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `DISTANCE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct DenseVectorHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
DenseVectorHandle: send native OP DISTANCE to the existing `dense_vector` key.
The server applies `dense_vector` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `vector`, `metric`.
Reference argument example: {"vector":[1.0,0.0,0.5],"metric":"cosine"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function DenseVectorHandle(c::NativeClient, key::AbstractString)
    return DenseVectorHandle(c, String(key), "dense_vector")
end

"""
dense_vector: send native OP DISTANCE to the existing `dense_vector` key.
The server applies `dense_vector` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `vector`, `metric`.
Reference argument example: {"vector":[1.0,0.0,0.5],"metric":"cosine"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
dense_vector(c::NativeClient, key::AbstractString) = DenseVectorHandle(c, key)

"""
op_distance: send native OP DISTANCE to the existing `dense_vector` key.
The server applies `dense_vector` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `vector`, `metric`.
Reference argument example: {"vector":[1.0,0.0,0.5],"metric":"cosine"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_distance(h::DenseVectorHandle, args = Dict{String,Any}()) = operation(h, "DISTANCE", args)

"""
DequeHandle: typed facade for the registered `deque` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `capacity`.
Supported named operations: `PUSH_BACK`, `PUSH_FRONT`, `LEN`, `POP_FRONT`, `POP_BACK`, `VALUES`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct DequeHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
DequeHandle: send native OP PUSH_BACK to the existing `deque` key.
The server applies `deque` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
DequeHandle(c::NativeClient, key::AbstractString) = DequeHandle(c, String(key), "deque")

"""
deque: send native OP PUSH_BACK to the existing `deque` key.
The server applies `deque` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
deque(c::NativeClient, key::AbstractString) = DequeHandle(c, key)

"""
op_push_back: send native OP PUSH_BACK to the existing `deque` key.
The server applies `deque` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_push_back(h::DequeHandle, args = Dict{String,Any}()) = operation(h, "PUSH_BACK", args)

"""
op_push_front: send native OP PUSH_FRONT to the existing `deque` key.
The server applies `deque` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"integer","value":7}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_push_front(h::DequeHandle, args = Dict{String,Any}()) = operation(h, "PUSH_FRONT", args)

"""
op_len: send native OP LEN to the existing `deque` key.
The server applies `deque` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::DequeHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_pop_front: send native OP POP_FRONT to the existing `deque` key.
The server applies `deque` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_pop_front(h::DequeHandle, args = Dict{String,Any}()) = operation(h, "POP_FRONT", args)

"""
op_pop_back: send native OP POP_BACK to the existing `deque` key.
The server applies `deque` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_pop_back(h::DequeHandle, args = Dict{String,Any}()) = operation(h, "POP_BACK", args)

"""
op_values: send native OP VALUES to the existing `deque` key.
The server applies `deque` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_values(h::DequeHandle, args = Dict{String,Any}()) = operation(h, "VALUES", args)

"""
DurationHandle: typed facade for the registered `duration` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `ADD`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct DurationHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
DurationHandle: send native OP ADD to the existing `duration` key.
The server applies `duration` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta_ms`.
Reference argument example: {"delta_ms":1000}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
DurationHandle(c::NativeClient, key::AbstractString) = DurationHandle(c, String(key), "duration")

"""
duration: send native OP ADD to the existing `duration` key.
The server applies `duration` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta_ms`.
Reference argument example: {"delta_ms":1000}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
duration(c::NativeClient, key::AbstractString) = DurationHandle(c, key)

"""
op_add: send native OP ADD to the existing `duration` key.
The server applies `duration` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta_ms`.
Reference argument example: {"delta_ms":1000}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::DurationHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
EventLogHandle: typed facade for the registered `event_log` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `APPEND`, `LEN`, `READ`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct EventLogHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
EventLogHandle: send native OP APPEND to the existing `event_log` key.
The server applies `event_log` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `event_type`, `aggregate_id`, `payload`.
Reference argument example: {"event_type":"created","aggregate_id":"agg1","payload":{"type":"utf8_string","value":"born"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
EventLogHandle(c::NativeClient, key::AbstractString) = EventLogHandle(c, String(key), "event_log")

"""
event_log: send native OP APPEND to the existing `event_log` key.
The server applies `event_log` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `event_type`, `aggregate_id`, `payload`.
Reference argument example: {"event_type":"created","aggregate_id":"agg1","payload":{"type":"utf8_string","value":"born"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
event_log(c::NativeClient, key::AbstractString) = EventLogHandle(c, key)

"""
op_append: send native OP APPEND to the existing `event_log` key.
The server applies `event_log` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `event_type`, `aggregate_id`, `payload`.
Reference argument example: {"event_type":"created","aggregate_id":"agg1","payload":{"type":"utf8_string","value":"born"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_append(h::EventLogHandle, args = Dict{String,Any}()) = operation(h, "APPEND", args)

"""
op_len: send native OP LEN to the existing `event_log` key.
The server applies `event_log` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::EventLogHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_read: send native OP READ to the existing `event_log` key.
The server applies `event_log` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `count`.
Reference argument example: {"from":1,"count":100}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_read(h::EventLogHandle, args = Dict{String,Any}()) = operation(h, "READ", args)

"""
FifoQueueHandle: typed facade for the registered `fifo_queue` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ENQUEUE`, `PEEK`, `DEQUEUE`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct FifoQueueHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
FifoQueueHandle: send native OP ENQUEUE to the existing `fifo_queue` key.
The server applies `fifo_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"first"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function FifoQueueHandle(c::NativeClient, key::AbstractString)
    return FifoQueueHandle(c, String(key), "fifo_queue")
end

"""
fifo_queue: send native OP ENQUEUE to the existing `fifo_queue` key.
The server applies `fifo_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"first"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
fifo_queue(c::NativeClient, key::AbstractString) = FifoQueueHandle(c, key)

"""
op_enqueue: send native OP ENQUEUE to the existing `fifo_queue` key.
The server applies `fifo_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"first"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_enqueue(h::FifoQueueHandle, args = Dict{String,Any}()) = operation(h, "ENQUEUE", args)

"""
op_peek: send native OP PEEK to the existing `fifo_queue` key.
The server applies `fifo_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_peek(h::FifoQueueHandle, args = Dict{String,Any}()) = operation(h, "PEEK", args)

"""
op_dequeue: send native OP DEQUEUE to the existing `fifo_queue` key.
The server applies `fifo_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_dequeue(h::FifoQueueHandle, args = Dict{String,Any}()) = operation(h, "DEQUEUE", args)

"""
op_len: send native OP LEN to the existing `fifo_queue` key.
The server applies `fifo_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::FifoQueueHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
FlatVectorIndexHandle: typed facade for the registered `flat_vector_index` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `dim`, `metric`.
Supported named operations: `ADD`, `SEARCH`, `REMOVE`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct FlatVectorIndexHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
FlatVectorIndexHandle: send native OP ADD to the existing `flat_vector_index` key.
The server applies `flat_vector_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function FlatVectorIndexHandle(c::NativeClient, key::AbstractString)
    return FlatVectorIndexHandle(c, String(key), "flat_vector_index")
end

"""
flat_vector_index: send native OP ADD to the existing `flat_vector_index` key.
The server applies `flat_vector_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
flat_vector_index(c::NativeClient, key::AbstractString) = FlatVectorIndexHandle(c, key)

"""
op_add: send native OP ADD to the existing `flat_vector_index` key.
The server applies `flat_vector_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::FlatVectorIndexHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_search: send native OP SEARCH to the existing `flat_vector_index` key.
The server applies `flat_vector_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `vector`, `k`.
Reference argument example: {"vector":[1,0,0],"k":1}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_search(h::FlatVectorIndexHandle, args = Dict{String,Any}()) = operation(h, "SEARCH", args)

"""
op_remove: send native OP REMOVE to the existing `flat_vector_index` key.
The server applies `flat_vector_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`.
Reference argument example: {"id":"v1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::FlatVectorIndexHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
op_len: send native OP LEN to the existing `flat_vector_index` key.
The server applies `flat_vector_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::FlatVectorIndexHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
FloatHandle: typed facade for the registered `float` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `ADD`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct FloatHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
FloatHandle: send native OP ADD to the existing `float` key.
The server applies `float` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":0.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
FloatHandle(c::NativeClient, key::AbstractString) = FloatHandle(c, String(key), "float")

"""
float: send native OP ADD to the existing `float` key.
The server applies `float` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":0.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
float(c::NativeClient, key::AbstractString) = FloatHandle(c, key)

"""
op_add: send native OP ADD to the existing `float` key.
The server applies `float` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":0.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::FloatHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
FullTextDocumentHandle: typed facade for the registered `full_text_document` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `id`, `metadata`.
Supported named operations: `ADD_TEXT`, `ADD_TAG`, `ADD_NUMERIC`, `SNAPSHOT`, `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct FullTextDocumentHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
FullTextDocumentHandle: send native OP ADD_TEXT to the existing `full_text_document` key.
The server applies `full_text_document` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`, `weight`.
Reference argument example: {"name":"body","value":"hello amaquet world","weight":2}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function FullTextDocumentHandle(c::NativeClient, key::AbstractString)
    return FullTextDocumentHandle(c, String(key), "full_text_document")
end

"""
full_text_document: send native OP ADD_TEXT to the existing `full_text_document` key.
The server applies `full_text_document` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`, `weight`.
Reference argument example: {"name":"body","value":"hello amaquet world","weight":2}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
full_text_document(c::NativeClient, key::AbstractString) = FullTextDocumentHandle(c, key)

"""
op_add_text: send native OP ADD_TEXT to the existing `full_text_document` key.
The server applies `full_text_document` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`, `weight`.
Reference argument example: {"name":"body","value":"hello amaquet world","weight":2}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add_text(h::FullTextDocumentHandle, args = Dict{String,Any}()) = operation(h, "ADD_TEXT", args)

"""
op_add_tag: send native OP ADD_TAG to the existing `full_text_document` key.
The server applies `full_text_document` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `values`.
Reference argument example: {"name":"tags","values":["go","memory"]}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add_tag(h::FullTextDocumentHandle, args = Dict{String,Any}()) = operation(h, "ADD_TAG", args)

"""
op_add_numeric: send native OP ADD_NUMERIC to the existing `full_text_document` key.
The server applies `full_text_document` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`.
Reference argument example: {"name":"score","value":9.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
function op_add_numeric(h::FullTextDocumentHandle, args = Dict{String,Any}())
    return operation(h, "ADD_NUMERIC", args)
end

"""
op_snapshot: send native OP SNAPSHOT to the existing `full_text_document` key.
The server applies `full_text_document` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_snapshot(h::FullTextDocumentHandle, args = Dict{String,Any}()) = operation(h, "SNAPSHOT", args)

"""
op_get: send native OP GET to the existing `full_text_document` key.
The server applies `full_text_document` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::FullTextDocumentHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
GaugeSeriesHandle: typed facade for the registered `gauge_series` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `labels`.
Supported named operations: `SET`, `LAST`, `RANGE`, `AGGREGATE`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct GaugeSeriesHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
GaugeSeriesHandle: send native OP SET to the existing `gauge_series` key.
The server applies `gauge_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1000,"value":42.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function GaugeSeriesHandle(c::NativeClient, key::AbstractString)
    return GaugeSeriesHandle(c, String(key), "gauge_series")
end

"""
gauge_series: send native OP SET to the existing `gauge_series` key.
The server applies `gauge_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1000,"value":42.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
gauge_series(c::NativeClient, key::AbstractString) = GaugeSeriesHandle(c, key)

"""
op_set: send native OP SET to the existing `gauge_series` key.
The server applies `gauge_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1000,"value":42.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::GaugeSeriesHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_last: send native OP LAST to the existing `gauge_series` key.
The server applies `gauge_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_last(h::GaugeSeriesHandle, args = Dict{String,Any}()) = operation(h, "LAST", args)

"""
op_range: send native OP RANGE to the existing `gauge_series` key.
The server applies `gauge_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`.
Reference argument example: {"from":0,"to":3000}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_range(h::GaugeSeriesHandle, args = Dict{String,Any}()) = operation(h, "RANGE", args)

"""
op_aggregate: send native OP AGGREGATE to the existing `gauge_series` key.
The server applies `gauge_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`, `bucket_ms`, `aggregation`.
Reference argument example: {"from":0,"to":3000,"bucket_ms":1000,"aggregation":"avg"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_aggregate(h::GaugeSeriesHandle, args = Dict{String,Any}()) = operation(h, "AGGREGATE", args)

"""
op_len: send native OP LEN to the existing `gauge_series` key.
The server applies `gauge_series` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::GaugeSeriesHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
GeoPointHandle: typed facade for the registered `geo_point` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `DISTANCE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct GeoPointHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
GeoPointHandle: send native OP DISTANCE to the existing `geo_point` key.
The server applies `geo_point` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.5995,"Lon":120.9842}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
GeoPointHandle(c::NativeClient, key::AbstractString) = GeoPointHandle(c, String(key), "geo_point")

"""
geo_point: send native OP DISTANCE to the existing `geo_point` key.
The server applies `geo_point` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.5995,"Lon":120.9842}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
geo_point(c::NativeClient, key::AbstractString) = GeoPointHandle(c, key)

"""
op_distance: send native OP DISTANCE to the existing `geo_point` key.
The server applies `geo_point` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.5995,"Lon":120.9842}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_distance(h::GeoPointHandle, args = Dict{String,Any}()) = operation(h, "DISTANCE", args)

"""
GeoSpatialIndexHandle: typed facade for the registered `geo_spatial_index` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `RADIUS`, `REMOVE`, `BOX`, `POLYGON`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct GeoSpatialIndexHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
GeoSpatialIndexHandle: send native OP ADD to the existing `geo_spatial_index` key.
The server applies `geo_spatial_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `point`, `metadata`.
Reference argument example: {"id":"manila","point":{"Lat":14.5995,"Lon":120.9842},"metadata":{"country":"PH"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function GeoSpatialIndexHandle(c::NativeClient, key::AbstractString)
    return GeoSpatialIndexHandle(c, String(key), "geo_spatial_index")
end

"""
geo_spatial_index: send native OP ADD to the existing `geo_spatial_index` key.
The server applies `geo_spatial_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `point`, `metadata`.
Reference argument example: {"id":"manila","point":{"Lat":14.5995,"Lon":120.9842},"metadata":{"country":"PH"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
geo_spatial_index(c::NativeClient, key::AbstractString) = GeoSpatialIndexHandle(c, key)

"""
op_add: send native OP ADD to the existing `geo_spatial_index` key.
The server applies `geo_spatial_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `point`, `metadata`.
Reference argument example: {"id":"manila","point":{"Lat":14.5995,"Lon":120.9842},"metadata":{"country":"PH"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::GeoSpatialIndexHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_radius: send native OP RADIUS to the existing `geo_spatial_index` key.
The server applies `geo_spatial_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `center`, `radius_meters`, `limit`.
Reference argument example: {"center":{"Lat":14.5995,"Lon":120.9842},"radius_meters":1000,"limit":10}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_radius(h::GeoSpatialIndexHandle, args = Dict{String,Any}()) = operation(h, "RADIUS", args)

"""
op_remove: send native OP REMOVE to the existing `geo_spatial_index` key.
The server applies `geo_spatial_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`.
Reference argument example: {"id":"manila"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::GeoSpatialIndexHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
op_box: send native OP BOX to the existing `geo_spatial_index` key.
The server applies `geo_spatial_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `box`.
Reference argument example: {"box":{"MinLat":14.0,"MinLon":120.0,"MaxLat":15.0,"MaxLon":122.0}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_box(h::GeoSpatialIndexHandle, args = Dict{String,Any}()) = operation(h, "BOX", args)

"""
op_polygon: send native OP POLYGON to the existing `geo_spatial_index` key.
The server applies `geo_spatial_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `points`.
Reference argument example: {"points":[{"Lat":14.5,"Lon":120.9},{"Lat":14.7,"Lon":120.9},{"Lat":14.6,"Lon":121.1}]}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_polygon(h::GeoSpatialIndexHandle, args = Dict{String,Any}()) = operation(h, "POLYGON", args)

"""
GeospatialSecondaryIndexHandle: typed facade for the registered `geospatial_secondary_index` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `RADIUS`, `REMOVE`, `BOX`, `POLYGON`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct GeospatialSecondaryIndexHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
GeospatialSecondaryIndexHandle: send native OP ADD to the existing `geospatial_secondary_index` key.
The server applies `geospatial_secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `point`, `metadata`.
Reference argument example: {"id":"manila","point":{"Lat":14.5995,"Lon":120.9842},"metadata":{"country":"PH"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function GeospatialSecondaryIndexHandle(c::NativeClient, key::AbstractString)
    return GeospatialSecondaryIndexHandle(c, String(key), "geospatial_secondary_index")
end

"""
geospatial_secondary_index: send native OP ADD to the existing `geospatial_secondary_index` key.
The server applies `geospatial_secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `point`, `metadata`.
Reference argument example: {"id":"manila","point":{"Lat":14.5995,"Lon":120.9842},"metadata":{"country":"PH"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function geospatial_secondary_index(c::NativeClient, key::AbstractString)
    return GeospatialSecondaryIndexHandle(c, key)
end

"""
op_add: send native OP ADD to the existing `geospatial_secondary_index` key.
The server applies `geospatial_secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `point`, `metadata`.
Reference argument example: {"id":"manila","point":{"Lat":14.5995,"Lon":120.9842},"metadata":{"country":"PH"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::GeospatialSecondaryIndexHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_radius: send native OP RADIUS to the existing `geospatial_secondary_index` key.
The server applies `geospatial_secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `center`, `radius_meters`, `limit`.
Reference argument example: {"center":{"Lat":14.5995,"Lon":120.9842},"radius_meters":100,"limit":5}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
function op_radius(h::GeospatialSecondaryIndexHandle, args = Dict{String,Any}())
    return operation(h, "RADIUS", args)
end

"""
op_remove: send native OP REMOVE to the existing `geospatial_secondary_index` key.
The server applies `geospatial_secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`.
Reference argument example: {"id":"manila"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
function op_remove(h::GeospatialSecondaryIndexHandle, args = Dict{String,Any}())
    return operation(h, "REMOVE", args)
end

"""
op_box: send native OP BOX to the existing `geospatial_secondary_index` key.
The server applies `geospatial_secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `box`.
Reference argument example: {"box":{"MinLat":14.0,"MinLon":120.0,"MaxLat":15.0,"MaxLon":122.0}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_box(h::GeospatialSecondaryIndexHandle, args = Dict{String,Any}()) = operation(h, "BOX", args)

"""
op_polygon: send native OP POLYGON to the existing `geospatial_secondary_index` key.
The server applies `geospatial_secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `points`.
Reference argument example: {"points":[{"Lat":14.5,"Lon":120.9},{"Lat":14.7,"Lon":120.9},{"Lat":14.6,"Lon":121.1}]}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
function op_polygon(h::GeospatialSecondaryIndexHandle, args = Dict{String,Any}())
    return operation(h, "POLYGON", args)
end

"""
HashIndexHandle: typed facade for the registered `hash_index` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `LOOKUP`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct HashIndexHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
HashIndexHandle: send native OP ADD to the existing `hash_index` key.
The server applies `hash_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"blue","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function HashIndexHandle(c::NativeClient, key::AbstractString)
    return HashIndexHandle(c, String(key), "hash_index")
end

"""
hash_index: send native OP ADD to the existing `hash_index` key.
The server applies `hash_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"blue","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
hash_index(c::NativeClient, key::AbstractString) = HashIndexHandle(c, key)

"""
op_add: send native OP ADD to the existing `hash_index` key.
The server applies `hash_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"blue","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::HashIndexHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_lookup: send native OP LOOKUP to the existing `hash_index` key.
The server applies `hash_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"blue"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_lookup(h::HashIndexHandle, args = Dict{String,Any}()) = operation(h, "LOOKUP", args)

"""
op_remove: send native OP REMOVE to the existing `hash_index` key.
The server applies `hash_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"blue","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::HashIndexHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
HashmapHandle: typed facade for the registered `hashmap` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `SET`, `GET`, `DELETE`, `KEYS`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct HashmapHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
HashmapHandle: send native OP SET to the existing `hashmap` key.
The server applies `hashmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
HashmapHandle(c::NativeClient, key::AbstractString) = HashmapHandle(c, String(key), "hashmap")

"""
hashmap: send native OP SET to the existing `hashmap` key.
The server applies `hashmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
hashmap(c::NativeClient, key::AbstractString) = HashmapHandle(c, key)

"""
op_set: send native OP SET to the existing `hashmap` key.
The server applies `hashmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::HashmapHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `hashmap` key.
The server applies `hashmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`.
Reference argument example: {"field":"name"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::HashmapHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
op_delete: send native OP DELETE to the existing `hashmap` key.
The server applies `hashmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`.
Reference argument example: {"field":"name"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_delete(h::HashmapHandle, args = Dict{String,Any}()) = operation(h, "DELETE", args)

"""
op_keys: send native OP KEYS to the existing `hashmap` key.
The server applies `hashmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_keys(h::HashmapHandle, args = Dict{String,Any}()) = operation(h, "KEYS", args)

"""
HistogramHandle: typed facade for the registered `histogram` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `bounds`.
Supported named operations: `OBSERVE`, `SNAPSHOT`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct HistogramHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
HistogramHandle: send native OP OBSERVE to the existing `histogram` key.
The server applies `histogram` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":3}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
HistogramHandle(c::NativeClient, key::AbstractString) = HistogramHandle(c, String(key), "histogram")

"""
histogram: send native OP OBSERVE to the existing `histogram` key.
The server applies `histogram` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":3}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
histogram(c::NativeClient, key::AbstractString) = HistogramHandle(c, key)

"""
op_observe: send native OP OBSERVE to the existing `histogram` key.
The server applies `histogram` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":3}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_observe(h::HistogramHandle, args = Dict{String,Any}()) = operation(h, "OBSERVE", args)

"""
op_snapshot: send native OP SNAPSHOT to the existing `histogram` key.
The server applies `histogram` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_snapshot(h::HistogramHandle, args = Dict{String,Any}()) = operation(h, "SNAPSHOT", args)

"""
HnswIndexHandle: typed facade for the registered `hnsw_index` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `dim`, `metric`, `m`, `ef_search`.
Supported named operations: `ADD`, `SEARCH`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct HnswIndexHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
HnswIndexHandle: send native OP ADD to the existing `hnsw_index` key.
The server applies `hnsw_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function HnswIndexHandle(c::NativeClient, key::AbstractString)
    return HnswIndexHandle(c, String(key), "hnsw_index")
end

"""
hnsw_index: send native OP ADD to the existing `hnsw_index` key.
The server applies `hnsw_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
hnsw_index(c::NativeClient, key::AbstractString) = HnswIndexHandle(c, key)

"""
op_add: send native OP ADD to the existing `hnsw_index` key.
The server applies `hnsw_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::HnswIndexHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_search: send native OP SEARCH to the existing `hnsw_index` key.
The server applies `hnsw_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `vector`, `k`.
Reference argument example: {"vector":[1,0,0],"k":1}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_search(h::HnswIndexHandle, args = Dict{String,Any}()) = operation(h, "SEARCH", args)

"""
op_remove: send native OP REMOVE to the existing `hnsw_index` key.
The server applies `hnsw_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`.
Reference argument example: {"id":"v1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::HnswIndexHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
HyperloglogHandle: typed facade for the registered `hyperloglog` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `precision`.
Supported named operations: `ADD`, `COUNT`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct HyperloglogHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
HyperloglogHandle: send native OP ADD to the existing `hyperloglog` key.
The server applies `hyperloglog` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function HyperloglogHandle(c::NativeClient, key::AbstractString)
    return HyperloglogHandle(c, String(key), "hyperloglog")
end

"""
hyperloglog: send native OP ADD to the existing `hyperloglog` key.
The server applies `hyperloglog` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
hyperloglog(c::NativeClient, key::AbstractString) = HyperloglogHandle(c, key)

"""
op_add: send native OP ADD to the existing `hyperloglog` key.
The server applies `hyperloglog` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"alice"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::HyperloglogHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_count: send native OP COUNT to the existing `hyperloglog` key.
The server applies `hyperloglog` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_count(h::HyperloglogHandle, args = Dict{String,Any}()) = operation(h, "COUNT", args)

"""
IntegerHandle: typed facade for the registered `integer` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `ADD`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct IntegerHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
IntegerHandle: send native OP ADD to the existing `integer` key.
The server applies `integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":8}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
IntegerHandle(c::NativeClient, key::AbstractString) = IntegerHandle(c, String(key), "integer")

"""
integer: send native OP ADD to the existing `integer` key.
The server applies `integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":8}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
integer(c::NativeClient, key::AbstractString) = IntegerHandle(c, key)

"""
op_add: send native OP ADD to the existing `integer` key.
The server applies `integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":8}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::IntegerHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
InvertedIndexHandle: typed facade for the registered `inverted_index` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `INDEX`, `SEARCH`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct InvertedIndexHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
InvertedIndexHandle: send native OP INDEX to the existing `inverted_index` key.
The server applies `inverted_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `text`.
Reference argument example: {"id":"d1","text":"amaquet in-memory database"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function InvertedIndexHandle(c::NativeClient, key::AbstractString)
    return InvertedIndexHandle(c, String(key), "inverted_index")
end

"""
inverted_index: send native OP INDEX to the existing `inverted_index` key.
The server applies `inverted_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `text`.
Reference argument example: {"id":"d1","text":"amaquet in-memory database"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
inverted_index(c::NativeClient, key::AbstractString) = InvertedIndexHandle(c, key)

"""
op_index: send native OP INDEX to the existing `inverted_index` key.
The server applies `inverted_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `text`.
Reference argument example: {"id":"d1","text":"amaquet in-memory database"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_index(h::InvertedIndexHandle, args = Dict{String,Any}()) = operation(h, "INDEX", args)

"""
op_search: send native OP SEARCH to the existing `inverted_index` key.
The server applies `inverted_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `query`, `limit`.
Reference argument example: {"query":"memory","limit":10}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_search(h::InvertedIndexHandle, args = Dict{String,Any}()) = operation(h, "SEARCH", args)

"""
op_remove: send native OP REMOVE to the existing `inverted_index` key.
The server applies `inverted_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`.
Reference argument example: {"id":"d1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::InvertedIndexHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
JsonHandle: typed facade for the registered `json` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `SET`, `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct JsonHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
JsonHandle: send native OP SET to the existing `json` key.
The server applies `json` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"hello":"world","n":1}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
JsonHandle(c::NativeClient, key::AbstractString) = JsonHandle(c, String(key), "json")

"""
json: send native OP SET to the existing `json` key.
The server applies `json` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"hello":"world","n":1}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
json(c::NativeClient, key::AbstractString) = JsonHandle(c, key)

"""
op_set: send native OP SET to the existing `json` key.
The server applies `json` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"hello":"world","n":1}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::JsonHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `json` key.
The server applies `json` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::JsonHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
LeaseHandle: typed facade for the registered `lease` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ACQUIRE`, `HELD`, `RELEASE`, `RENEW`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct LeaseHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
LeaseHandle: send native OP ACQUIRE to the existing `lease` key.
The server applies `lease` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `owner`, `token`, `ttl_ms`.
Reference argument example: {"owner":"worker-a","token":"t1","ttl_ms":5000}.
Effects: May change server-side state; do not run as a read-only health check.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
LeaseHandle(c::NativeClient, key::AbstractString) = LeaseHandle(c, String(key), "lease")

"""
lease: send native OP ACQUIRE to the existing `lease` key.
The server applies `lease` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `owner`, `token`, `ttl_ms`.
Reference argument example: {"owner":"worker-a","token":"t1","ttl_ms":5000}.
Effects: May change server-side state; do not run as a read-only health check.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
lease(c::NativeClient, key::AbstractString) = LeaseHandle(c, key)

"""
op_acquire: send native OP ACQUIRE to the existing `lease` key.
The server applies `lease` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `owner`, `token`, `ttl_ms`.
Reference argument example: {"owner":"worker-a","token":"t1","ttl_ms":5000}.
Effects: May change server-side state; do not run as a read-only health check.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_acquire(h::LeaseHandle, args = Dict{String,Any}()) = operation(h, "ACQUIRE", args)

"""
op_held: send native OP HELD to the existing `lease` key.
The server applies `lease` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_held(h::LeaseHandle, args = Dict{String,Any}()) = operation(h, "HELD", args)

"""
op_release: send native OP RELEASE to the existing `lease` key.
The server applies `lease` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `token`.
Reference argument example: {"token":"t1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_release(h::LeaseHandle, args = Dict{String,Any}()) = operation(h, "RELEASE", args)

"""
op_renew: send native OP RENEW to the existing `lease` key.
The server applies `lease` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `token`, `ttl_ms`.
Reference argument example: {"token":"t1","ttl_ms":5000}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_renew(h::LeaseHandle, args = Dict{String,Any}()) = operation(h, "RENEW", args)

"""
LifoStackHandle: typed facade for the registered `lifo_stack` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `PUSH`, `PEEK`, `POP`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct LifoStackHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
LifoStackHandle: send native OP PUSH to the existing `lifo_stack` key.
The server applies `lifo_stack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"first"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function LifoStackHandle(c::NativeClient, key::AbstractString)
    return LifoStackHandle(c, String(key), "lifo_stack")
end

"""
lifo_stack: send native OP PUSH to the existing `lifo_stack` key.
The server applies `lifo_stack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"first"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
lifo_stack(c::NativeClient, key::AbstractString) = LifoStackHandle(c, key)

"""
op_push: send native OP PUSH to the existing `lifo_stack` key.
The server applies `lifo_stack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"first"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_push(h::LifoStackHandle, args = Dict{String,Any}()) = operation(h, "PUSH", args)

"""
op_peek: send native OP PEEK to the existing `lifo_stack` key.
The server applies `lifo_stack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_peek(h::LifoStackHandle, args = Dict{String,Any}()) = operation(h, "PEEK", args)

"""
op_pop: send native OP POP to the existing `lifo_stack` key.
The server applies `lifo_stack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_pop(h::LifoStackHandle, args = Dict{String,Any}()) = operation(h, "POP", args)

"""
op_len: send native OP LEN to the existing `lifo_stack` key.
The server applies `lifo_stack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::LifoStackHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
ListHandle: typed facade for the registered `list` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `PUSH_BACK`, `PUSH_FRONT`, `LEN`, `RANGE`, `POP_FRONT`, `POP_BACK`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct ListHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
ListHandle: send native OP PUSH_BACK to the existing `list` key.
The server applies `list` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
ListHandle(c::NativeClient, key::AbstractString) = ListHandle(c, String(key), "list")

"""
list: send native OP PUSH_BACK to the existing `list` key.
The server applies `list` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
list(c::NativeClient, key::AbstractString) = ListHandle(c, key)

"""
op_push_back: send native OP PUSH_BACK to the existing `list` key.
The server applies `list` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_push_back(h::ListHandle, args = Dict{String,Any}()) = operation(h, "PUSH_BACK", args)

"""
op_push_front: send native OP PUSH_FRONT to the existing `list` key.
The server applies `list` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"integer","value":7}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_push_front(h::ListHandle, args = Dict{String,Any}()) = operation(h, "PUSH_FRONT", args)

"""
op_len: send native OP LEN to the existing `list` key.
The server applies `list` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::ListHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_range: send native OP RANGE to the existing `list` key.
The server applies `list` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `start`, `stop`.
Reference argument example: {"start":0,"stop":-1}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_range(h::ListHandle, args = Dict{String,Any}()) = operation(h, "RANGE", args)

"""
op_pop_front: send native OP POP_FRONT to the existing `list` key.
The server applies `list` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_pop_front(h::ListHandle, args = Dict{String,Any}()) = operation(h, "POP_FRONT", args)

"""
op_pop_back: send native OP POP_BACK to the existing `list` key.
The server applies `list` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_pop_back(h::ListHandle, args = Dict{String,Any}()) = operation(h, "POP_BACK", args)

"""
LockHandle: typed facade for the registered `lock` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `TRY_LOCK`, `UNLOCK`, `RENEW`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct LockHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
LockHandle: send native OP TRY_LOCK to the existing `lock` key.
The server applies `lock` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `owner`, `token`, `ttl_ms`.
Reference argument example: {"owner":"worker-a","token":"t1","ttl_ms":5000}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
LockHandle(c::NativeClient, key::AbstractString) = LockHandle(c, String(key), "lock")

"""
lock: send native OP TRY_LOCK to the existing `lock` key.
The server applies `lock` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `owner`, `token`, `ttl_ms`.
Reference argument example: {"owner":"worker-a","token":"t1","ttl_ms":5000}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
lock(c::NativeClient, key::AbstractString) = LockHandle(c, key)

"""
op_try_lock: send native OP TRY_LOCK to the existing `lock` key.
The server applies `lock` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `owner`, `token`, `ttl_ms`.
Reference argument example: {"owner":"worker-a","token":"t1","ttl_ms":5000}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_try_lock(h::LockHandle, args = Dict{String,Any}()) = operation(h, "TRY_LOCK", args)

"""
op_unlock: send native OP UNLOCK to the existing `lock` key.
The server applies `lock` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `token`.
Reference argument example: {"token":"t1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_unlock(h::LockHandle, args = Dict{String,Any}()) = operation(h, "UNLOCK", args)

"""
op_renew: send native OP RENEW to the existing `lock` key.
The server applies `lock` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `token`, `ttl_ms`.
Reference argument example: {"token":"t1","ttl_ms":5000}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_renew(h::LockHandle, args = Dict{String,Any}()) = operation(h, "RENEW", args)

"""
MatrixHandle: typed facade for the registered `matrix` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `rows`, `cols`, `dtype`, `data`.
Supported named operations: `GET`, `SET`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct MatrixHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
MatrixHandle: send native OP GET to the existing `matrix` key.
The server applies `matrix` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `indices`.
Reference argument example: {"indices":[1,1]}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
MatrixHandle(c::NativeClient, key::AbstractString) = MatrixHandle(c, String(key), "matrix")

"""
matrix: send native OP GET to the existing `matrix` key.
The server applies `matrix` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `indices`.
Reference argument example: {"indices":[1,1]}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
matrix(c::NativeClient, key::AbstractString) = MatrixHandle(c, key)

"""
op_get: send native OP GET to the existing `matrix` key.
The server applies `matrix` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `indices`.
Reference argument example: {"indices":[1,1]}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::MatrixHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
op_set: send native OP SET to the existing `matrix` key.
The server applies `matrix` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `indices`, `value`.
Reference argument example: {"indices":[0,1],"value":9}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::MatrixHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_len: send native OP LEN to the existing `matrix` key.
The server applies `matrix` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::MatrixHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
MessagepackHandle: typed facade for the registered `messagepack` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct MessagepackHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
MessagepackHandle: send native OP GET to the existing `messagepack` key.
The server applies `messagepack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function MessagepackHandle(c::NativeClient, key::AbstractString)
    return MessagepackHandle(c, String(key), "messagepack")
end

"""
messagepack: send native OP GET to the existing `messagepack` key.
The server applies `messagepack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
messagepack(c::NativeClient, key::AbstractString) = MessagepackHandle(c, key)

"""
op_get: send native OP GET to the existing `messagepack` key.
The server applies `messagepack` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::MessagepackHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
MultimapHandle: typed facade for the registered `multimap` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `GET`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct MultimapHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
MultimapHandle: send native OP ADD to the existing `multimap` key.
The server applies `multimap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"tag","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
MultimapHandle(c::NativeClient, key::AbstractString) = MultimapHandle(c, String(key), "multimap")

"""
multimap: send native OP ADD to the existing `multimap` key.
The server applies `multimap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"tag","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
multimap(c::NativeClient, key::AbstractString) = MultimapHandle(c, key)

"""
op_add: send native OP ADD to the existing `multimap` key.
The server applies `multimap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"tag","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::MultimapHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_get: send native OP GET to the existing `multimap` key.
The server applies `multimap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`.
Reference argument example: {"field":"tag"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::MultimapHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
op_remove: send native OP REMOVE to the existing `multimap` key.
The server applies `multimap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"tag","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::MultimapHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
MultisetHandle: typed facade for the registered `multiset` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `COUNT`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct MultisetHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
MultisetHandle: send native OP ADD to the existing `multiset` key.
The server applies `multiset` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"},"count":3}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
MultisetHandle(c::NativeClient, key::AbstractString) = MultisetHandle(c, String(key), "multiset")

"""
multiset: send native OP ADD to the existing `multiset` key.
The server applies `multiset` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"},"count":3}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
multiset(c::NativeClient, key::AbstractString) = MultisetHandle(c, key)

"""
op_add: send native OP ADD to the existing `multiset` key.
The server applies `multiset` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"},"count":3}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::MultisetHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_count: send native OP COUNT to the existing `multiset` key.
The server applies `multiset` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_count(h::MultisetHandle, args = Dict{String,Any}()) = operation(h, "COUNT", args)

"""
op_remove: send native OP REMOVE to the existing `multiset` key.
The server applies `multiset` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"},"count":1}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::MultisetHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
NullHandle: typed facade for the registered `null` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct NullHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
NullHandle: typed facade for the registered `null` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
NullHandle(c::NativeClient, key::AbstractString) = NullHandle(c, String(key), "null")

"""
null: Provides the null operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
null(c::NativeClient, key::AbstractString) = NullHandle(c, key)

"""
NumericFieldHandle: typed facade for the registered `numeric_field` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `name`, `value`.
Supported named operations: `SET`, `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct NumericFieldHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
NumericFieldHandle: send native OP SET to the existing `numeric_field` key.
The server applies `numeric_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`.
Reference argument example: {"name":"score","value":99.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function NumericFieldHandle(c::NativeClient, key::AbstractString)
    return NumericFieldHandle(c, String(key), "numeric_field")
end

"""
numeric_field: send native OP SET to the existing `numeric_field` key.
The server applies `numeric_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`.
Reference argument example: {"name":"score","value":99.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
numeric_field(c::NativeClient, key::AbstractString) = NumericFieldHandle(c, key)

"""
op_set: send native OP SET to the existing `numeric_field` key.
The server applies `numeric_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`.
Reference argument example: {"name":"score","value":99.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::NumericFieldHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `numeric_field` key.
The server applies `numeric_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::NumericFieldHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
OrderedMapHandle: typed facade for the registered `ordered_map` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `SET`, `GET`, `DELETE`, `ENTRIES`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct OrderedMapHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
OrderedMapHandle: send native OP SET to the existing `ordered_map` key.
The server applies `ordered_map` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function OrderedMapHandle(c::NativeClient, key::AbstractString)
    return OrderedMapHandle(c, String(key), "ordered_map")
end

"""
ordered_map: send native OP SET to the existing `ordered_map` key.
The server applies `ordered_map` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
ordered_map(c::NativeClient, key::AbstractString) = OrderedMapHandle(c, key)

"""
op_set: send native OP SET to the existing `ordered_map` key.
The server applies `ordered_map` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::OrderedMapHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `ordered_map` key.
The server applies `ordered_map` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`.
Reference argument example: {"field":"name"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::OrderedMapHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
op_delete: send native OP DELETE to the existing `ordered_map` key.
The server applies `ordered_map` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`.
Reference argument example: {"field":"name"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_delete(h::OrderedMapHandle, args = Dict{String,Any}()) = operation(h, "DELETE", args)

"""
op_entries: send native OP ENTRIES to the existing `ordered_map` key.
The server applies `ordered_map` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_entries(h::OrderedMapHandle, args = Dict{String,Any}()) = operation(h, "ENTRIES", args)

"""
OrderedSetHandle: typed facade for the registered `ordered_set` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `VALUES`, `REMOVE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct OrderedSetHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
OrderedSetHandle: send native OP ADD to the existing `ordered_set` key.
The server applies `ordered_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function OrderedSetHandle(c::NativeClient, key::AbstractString)
    return OrderedSetHandle(c, String(key), "ordered_set")
end

"""
ordered_set: send native OP ADD to the existing `ordered_set` key.
The server applies `ordered_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
ordered_set(c::NativeClient, key::AbstractString) = OrderedSetHandle(c, key)

"""
op_add: send native OP ADD to the existing `ordered_set` key.
The server applies `ordered_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::OrderedSetHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_values: send native OP VALUES to the existing `ordered_set` key.
The server applies `ordered_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_values(h::OrderedSetHandle, args = Dict{String,Any}()) = operation(h, "VALUES", args)

"""
op_remove: send native OP REMOVE to the existing `ordered_set` key.
The server applies `ordered_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::OrderedSetHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
PersistentTopicHandle: typed facade for the registered `persistent_topic` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `max_messages`.
Supported named operations: `PUBLISH`, `READ`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct PersistentTopicHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
PersistentTopicHandle: send native OP PUBLISH to the existing `persistent_topic` key.
The server applies `persistent_topic` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `message_key`, `value`.
Reference argument example: {"message_key":"m1","value":{"type":"utf8_string","value":"hello"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function PersistentTopicHandle(c::NativeClient, key::AbstractString)
    return PersistentTopicHandle(c, String(key), "persistent_topic")
end

"""
persistent_topic: send native OP PUBLISH to the existing `persistent_topic` key.
The server applies `persistent_topic` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `message_key`, `value`.
Reference argument example: {"message_key":"m1","value":{"type":"utf8_string","value":"hello"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
persistent_topic(c::NativeClient, key::AbstractString) = PersistentTopicHandle(c, key)

"""
op_publish: send native OP PUBLISH to the existing `persistent_topic` key.
The server applies `persistent_topic` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `message_key`, `value`.
Reference argument example: {"message_key":"m1","value":{"type":"utf8_string","value":"hello"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_publish(h::PersistentTopicHandle, args = Dict{String,Any}()) = operation(h, "PUBLISH", args)

"""
op_read: send native OP READ to the existing `persistent_topic` key.
The server applies `persistent_topic` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `count`.
Reference argument example: {"from":0,"count":10}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_read(h::PersistentTopicHandle, args = Dict{String,Any}()) = operation(h, "READ", args)

"""
PolygonHandle: typed facade for the registered `polygon` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `CONTAINS`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct PolygonHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
PolygonHandle: send native OP CONTAINS to the existing `polygon` key.
The server applies `polygon` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.6,"Lon":121.0}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
PolygonHandle(c::NativeClient, key::AbstractString) = PolygonHandle(c, String(key), "polygon")

"""
polygon: send native OP CONTAINS to the existing `polygon` key.
The server applies `polygon` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.6,"Lon":121.0}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
polygon(c::NativeClient, key::AbstractString) = PolygonHandle(c, key)

"""
op_contains: send native OP CONTAINS to the existing `polygon` key.
The server applies `polygon` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `point`.
Reference argument example: {"point":{"Lat":14.6,"Lon":121.0}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_contains(h::PolygonHandle, args = Dict{String,Any}()) = operation(h, "CONTAINS", args)

"""
PriorityQueueHandle: typed facade for the registered `priority_queue` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ENQUEUE`, `LEN`, `DEQUEUE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct PriorityQueueHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
PriorityQueueHandle: send native OP ENQUEUE to the existing `priority_queue` key.
The server applies `priority_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `priority`.
Reference argument example: {"value":{"type":"utf8_string","value":"low"},"priority":1}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function PriorityQueueHandle(c::NativeClient, key::AbstractString)
    return PriorityQueueHandle(c, String(key), "priority_queue")
end

"""
priority_queue: send native OP ENQUEUE to the existing `priority_queue` key.
The server applies `priority_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `priority`.
Reference argument example: {"value":{"type":"utf8_string","value":"low"},"priority":1}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
priority_queue(c::NativeClient, key::AbstractString) = PriorityQueueHandle(c, key)

"""
op_enqueue: send native OP ENQUEUE to the existing `priority_queue` key.
The server applies `priority_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `priority`.
Reference argument example: {"value":{"type":"utf8_string","value":"low"},"priority":1}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_enqueue(h::PriorityQueueHandle, args = Dict{String,Any}()) = operation(h, "ENQUEUE", args)

"""
op_len: send native OP LEN to the existing `priority_queue` key.
The server applies `priority_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::PriorityQueueHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_dequeue: send native OP DEQUEUE to the existing `priority_queue` key.
The server applies `priority_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_dequeue(h::PriorityQueueHandle, args = Dict{String,Any}()) = operation(h, "DEQUEUE", args)

"""
PubsubHandle: typed facade for the registered `pubsub` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `PUBLISH`, `STATS`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct PubsubHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
PubsubHandle: send native OP PUBLISH to the existing `pubsub` key.
The server applies `pubsub` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `channel`, `value`.
Reference argument example: {"channel":"events","value":{"type":"utf8_string","value":"ping"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
PubsubHandle(c::NativeClient, key::AbstractString) = PubsubHandle(c, String(key), "pubsub")

"""
pubsub: send native OP PUBLISH to the existing `pubsub` key.
The server applies `pubsub` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `channel`, `value`.
Reference argument example: {"channel":"events","value":{"type":"utf8_string","value":"ping"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
pubsub(c::NativeClient, key::AbstractString) = PubsubHandle(c, key)

"""
op_publish: send native OP PUBLISH to the existing `pubsub` key.
The server applies `pubsub` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `channel`, `value`.
Reference argument example: {"channel":"events","value":{"type":"utf8_string","value":"ping"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_publish(h::PubsubHandle, args = Dict{String,Any}()) = operation(h, "PUBLISH", args)

"""
op_stats: send native OP STATS to the existing `pubsub` key.
The server applies `pubsub` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_stats(h::PubsubHandle, args = Dict{String,Any}()) = operation(h, "STATS", args)

"""
QuantizedVectorHandle: typed facade for the registered `quantized_vector` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `DEQUANTIZE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct QuantizedVectorHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
QuantizedVectorHandle: send native OP DEQUANTIZE to the existing `quantized_vector` key.
The server applies `quantized_vector` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function QuantizedVectorHandle(c::NativeClient, key::AbstractString)
    return QuantizedVectorHandle(c, String(key), "quantized_vector")
end

"""
quantized_vector: send native OP DEQUANTIZE to the existing `quantized_vector` key.
The server applies `quantized_vector` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
quantized_vector(c::NativeClient, key::AbstractString) = QuantizedVectorHandle(c, key)

"""
op_dequantize: send native OP DEQUANTIZE to the existing `quantized_vector` key.
The server applies `quantized_vector` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
function op_dequantize(h::QuantizedVectorHandle, args = Dict{String,Any}())
    return operation(h, "DEQUANTIZE", args)
end

"""
RadixTreeHandle: typed facade for the registered `radix_tree` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `INSERT`, `PREFIX`, `EXACT`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct RadixTreeHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
RadixTreeHandle: send native OP INSERT to the existing `radix_tree` key.
The server applies `radix_tree` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"amaquet","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function RadixTreeHandle(c::NativeClient, key::AbstractString)
    return RadixTreeHandle(c, String(key), "radix_tree")
end

"""
radix_tree: send native OP INSERT to the existing `radix_tree` key.
The server applies `radix_tree` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"amaquet","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
radix_tree(c::NativeClient, key::AbstractString) = RadixTreeHandle(c, key)

"""
op_insert: send native OP INSERT to the existing `radix_tree` key.
The server applies `radix_tree` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"amaquet","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_insert(h::RadixTreeHandle, args = Dict{String,Any}()) = operation(h, "INSERT", args)

"""
op_prefix: send native OP PREFIX to the existing `radix_tree` key.
The server applies `radix_tree` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `prefix`, `limit`.
Reference argument example: {"prefix":"ama","limit":10}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_prefix(h::RadixTreeHandle, args = Dict{String,Any}()) = operation(h, "PREFIX", args)

"""
op_exact: send native OP EXACT to the existing `radix_tree` key.
The server applies `radix_tree` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"amaquet"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_exact(h::RadixTreeHandle, args = Dict{String,Any}()) = operation(h, "EXACT", args)

"""
RateLimitBucketHandle: typed facade for the registered `rate_limit_bucket` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `capacity`, `refill_per_second`.
Supported named operations: `ALLOW`, `REMAINING`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct RateLimitBucketHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
RateLimitBucketHandle: send native OP ALLOW to the existing `rate_limit_bucket` key.
The server applies `rate_limit_bucket` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `cost`.
Reference argument example: {"cost":1}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function RateLimitBucketHandle(c::NativeClient, key::AbstractString)
    return RateLimitBucketHandle(c, String(key), "rate_limit_bucket")
end

"""
rate_limit_bucket: send native OP ALLOW to the existing `rate_limit_bucket` key.
The server applies `rate_limit_bucket` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `cost`.
Reference argument example: {"cost":1}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
rate_limit_bucket(c::NativeClient, key::AbstractString) = RateLimitBucketHandle(c, key)

"""
op_allow: send native OP ALLOW to the existing `rate_limit_bucket` key.
The server applies `rate_limit_bucket` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `cost`.
Reference argument example: {"cost":1}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_allow(h::RateLimitBucketHandle, args = Dict{String,Any}()) = operation(h, "ALLOW", args)

"""
op_remaining: send native OP REMAINING to the existing `rate_limit_bucket` key.
The server applies `rate_limit_bucket` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remaining(h::RateLimitBucketHandle, args = Dict{String,Any}()) = operation(h, "REMAINING", args)

"""
RecordHandle: typed facade for the registered `record` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `schema`.
Supported named operations: `SET`, `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct RecordHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
RecordHandle: send native OP SET to the existing `record` key.
The server applies `record` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alice"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
RecordHandle(c::NativeClient, key::AbstractString) = RecordHandle(c, String(key), "record")

"""
record: send native OP SET to the existing `record` key.
The server applies `record` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alice"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
record(c::NativeClient, key::AbstractString) = RecordHandle(c, key)

"""
op_set: send native OP SET to the existing `record` key.
The server applies `record` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"name","value":{"type":"utf8_string","value":"alice"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::RecordHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `record` key.
The server applies `record` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`.
Reference argument example: {"field":"name"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::RecordHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
ReliableQueueHandle: typed facade for the registered `reliable_queue` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `max_attempts`.
Supported named operations: `ENQUEUE`, `CLAIM`, `ACK`, `NACK`, `STATS`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct ReliableQueueHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
ReliableQueueHandle: send native OP ENQUEUE to the existing `reliable_queue` key.
The server applies `reliable_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `value`.
Reference argument example: {"id":"job1","value":{"type":"utf8_string","value":"work"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function ReliableQueueHandle(c::NativeClient, key::AbstractString)
    return ReliableQueueHandle(c, String(key), "reliable_queue")
end

"""
reliable_queue: send native OP ENQUEUE to the existing `reliable_queue` key.
The server applies `reliable_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `value`.
Reference argument example: {"id":"job1","value":{"type":"utf8_string","value":"work"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
reliable_queue(c::NativeClient, key::AbstractString) = ReliableQueueHandle(c, key)

"""
op_enqueue: send native OP ENQUEUE to the existing `reliable_queue` key.
The server applies `reliable_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `value`.
Reference argument example: {"id":"job1","value":{"type":"utf8_string","value":"work"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_enqueue(h::ReliableQueueHandle, args = Dict{String,Any}()) = operation(h, "ENQUEUE", args)

"""
op_claim: send native OP CLAIM to the existing `reliable_queue` key.
The server applies `reliable_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `lease_ms`.
Reference argument example: {"lease_ms":5000}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_claim(h::ReliableQueueHandle, args = Dict{String,Any}()) = operation(h, "CLAIM", args)

"""
op_ack: send native OP ACK to the existing `reliable_queue` key.
The server applies `reliable_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`.
Reference argument example: {"id":"job1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_ack(h::ReliableQueueHandle, args = Dict{String,Any}()) = operation(h, "ACK", args)

"""
op_nack: send native OP NACK to the existing `reliable_queue` key.
The server applies `reliable_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`.
Reference argument example: {"id":"job1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_nack(h::ReliableQueueHandle, args = Dict{String,Any}()) = operation(h, "NACK", args)

"""
op_stats: send native OP STATS to the existing `reliable_queue` key.
The server applies `reliable_queue` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_stats(h::ReliableQueueHandle, args = Dict{String,Any}()) = operation(h, "STATS", args)

"""
RingBufferHandle: typed facade for the registered `ring_buffer` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `capacity`.
Supported named operations: `PUSH`, `LEN`, `VALUES`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct RingBufferHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
RingBufferHandle: send native OP PUSH to the existing `ring_buffer` key.
The server applies `ring_buffer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"a"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function RingBufferHandle(c::NativeClient, key::AbstractString)
    return RingBufferHandle(c, String(key), "ring_buffer")
end

"""
ring_buffer: send native OP PUSH to the existing `ring_buffer` key.
The server applies `ring_buffer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"a"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
ring_buffer(c::NativeClient, key::AbstractString) = RingBufferHandle(c, key)

"""
op_push: send native OP PUSH to the existing `ring_buffer` key.
The server applies `ring_buffer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"a"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_push(h::RingBufferHandle, args = Dict{String,Any}()) = operation(h, "PUSH", args)

"""
op_len: send native OP LEN to the existing `ring_buffer` key.
The server applies `ring_buffer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::RingBufferHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_values: send native OP VALUES to the existing `ring_buffer` key.
The server applies `ring_buffer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_values(h::RingBufferHandle, args = Dict{String,Any}()) = operation(h, "VALUES", args)

"""
RoaringBitmapHandle: typed facade for the registered `roaring_bitmap` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `CONTAINS`, `CARDINALITY`, `REMOVE`, `VALUES`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct RoaringBitmapHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
RoaringBitmapHandle: send native OP ADD to the existing `roaring_bitmap` key.
The server applies `roaring_bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":42}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function RoaringBitmapHandle(c::NativeClient, key::AbstractString)
    return RoaringBitmapHandle(c, String(key), "roaring_bitmap")
end

"""
roaring_bitmap: send native OP ADD to the existing `roaring_bitmap` key.
The server applies `roaring_bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":42}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
roaring_bitmap(c::NativeClient, key::AbstractString) = RoaringBitmapHandle(c, key)

"""
op_add: send native OP ADD to the existing `roaring_bitmap` key.
The server applies `roaring_bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":42}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::RoaringBitmapHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_contains: send native OP CONTAINS to the existing `roaring_bitmap` key.
The server applies `roaring_bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":42}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_contains(h::RoaringBitmapHandle, args = Dict{String,Any}()) = operation(h, "CONTAINS", args)

"""
op_cardinality: send native OP CARDINALITY to the existing `roaring_bitmap` key.
The server applies `roaring_bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
function op_cardinality(h::RoaringBitmapHandle, args = Dict{String,Any}())
    return operation(h, "CARDINALITY", args)
end

"""
op_remove: send native OP REMOVE to the existing `roaring_bitmap` key.
The server applies `roaring_bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":42}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::RoaringBitmapHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
op_values: send native OP VALUES to the existing `roaring_bitmap` key.
The server applies `roaring_bitmap` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_values(h::RoaringBitmapHandle, args = Dict{String,Any}()) = operation(h, "VALUES", args)

"""
SecondaryIndexHandle: typed facade for the registered `secondary_index` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `LOOKUP`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct SecondaryIndexHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
SecondaryIndexHandle: send native OP ADD to the existing `secondary_index` key.
The server applies `secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`, `id`.
Reference argument example: {"field":"status","value":"active","id":"u1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function SecondaryIndexHandle(c::NativeClient, key::AbstractString)
    return SecondaryIndexHandle(c, String(key), "secondary_index")
end

"""
secondary_index: send native OP ADD to the existing `secondary_index` key.
The server applies `secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`, `id`.
Reference argument example: {"field":"status","value":"active","id":"u1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
secondary_index(c::NativeClient, key::AbstractString) = SecondaryIndexHandle(c, key)

"""
op_add: send native OP ADD to the existing `secondary_index` key.
The server applies `secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`, `id`.
Reference argument example: {"field":"status","value":"active","id":"u1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::SecondaryIndexHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_lookup: send native OP LOOKUP to the existing `secondary_index` key.
The server applies `secondary_index` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"status","value":"active"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_lookup(h::SecondaryIndexHandle, args = Dict{String,Any}()) = operation(h, "LOOKUP", args)

"""
SemaphoreHandle: typed facade for the registered `semaphore` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `limit`.
Supported named operations: `TRY_ACQUIRE`, `STATS`, `RELEASE`, `ACQUIRE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct SemaphoreHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
SemaphoreHandle: send native OP TRY_ACQUIRE to the existing `semaphore` key.
The server applies `semaphore` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
SemaphoreHandle(c::NativeClient, key::AbstractString) = SemaphoreHandle(c, String(key), "semaphore")

"""
semaphore: send native OP TRY_ACQUIRE to the existing `semaphore` key.
The server applies `semaphore` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
semaphore(c::NativeClient, key::AbstractString) = SemaphoreHandle(c, key)

"""
op_try_acquire: send native OP TRY_ACQUIRE to the existing `semaphore` key.
The server applies `semaphore` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_try_acquire(h::SemaphoreHandle, args = Dict{String,Any}()) = operation(h, "TRY_ACQUIRE", args)

"""
op_stats: send native OP STATS to the existing `semaphore` key.
The server applies `semaphore` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_stats(h::SemaphoreHandle, args = Dict{String,Any}()) = operation(h, "STATS", args)

"""
op_release: send native OP RELEASE to the existing `semaphore` key.
The server applies `semaphore` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_release(h::SemaphoreHandle, args = Dict{String,Any}()) = operation(h, "RELEASE", args)

"""
op_acquire: send native OP ACQUIRE to the existing `semaphore` key.
The server applies `semaphore` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: May change server-side state; do not run as a read-only health check.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_acquire(h::SemaphoreHandle, args = Dict{String,Any}()) = operation(h, "ACQUIRE", args)

"""
SetHandle: typed facade for the registered `set` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `CONTAINS`, `REMOVE`, `MEMBERS`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct SetHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
SetHandle: send native OP ADD to the existing `set` key.
The server applies `set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
SetHandle(c::NativeClient, key::AbstractString) = SetHandle(c, String(key), "set")

"""
set: send native OP ADD to the existing `set` key.
The server applies `set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
set(c::NativeClient, key::AbstractString) = SetHandle(c, key)

"""
op_add: send native OP ADD to the existing `set` key.
The server applies `set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::SetHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_contains: send native OP CONTAINS to the existing `set` key.
The server applies `set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_contains(h::SetHandle, args = Dict{String,Any}()) = operation(h, "CONTAINS", args)

"""
op_remove: send native OP REMOVE to the existing `set` key.
The server applies `set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::SetHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
op_members: send native OP MEMBERS to the existing `set` key.
The server applies `set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_members(h::SetHandle, args = Dict{String,Any}()) = operation(h, "MEMBERS", args)

"""
op_len: send native OP LEN to the existing `set` key.
The server applies `set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::SetHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
SortedSetHandle: typed facade for the registered `sorted_set` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `SCORE`, `REMOVE`, `RANGE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct SortedSetHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
SortedSetHandle: send native OP ADD to the existing `sorted_set` key.
The server applies `sorted_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `member`, `score`.
Reference argument example: {"member":{"type":"utf8_string","value":"alpha"},"score":10.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function SortedSetHandle(c::NativeClient, key::AbstractString)
    return SortedSetHandle(c, String(key), "sorted_set")
end

"""
sorted_set: send native OP ADD to the existing `sorted_set` key.
The server applies `sorted_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `member`, `score`.
Reference argument example: {"member":{"type":"utf8_string","value":"alpha"},"score":10.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
sorted_set(c::NativeClient, key::AbstractString) = SortedSetHandle(c, key)

"""
op_add: send native OP ADD to the existing `sorted_set` key.
The server applies `sorted_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `member`, `score`.
Reference argument example: {"member":{"type":"utf8_string","value":"alpha"},"score":10.5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::SortedSetHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_score: send native OP SCORE to the existing `sorted_set` key.
The server applies `sorted_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `member`.
Reference argument example: {"member":{"type":"utf8_string","value":"alpha"}}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_score(h::SortedSetHandle, args = Dict{String,Any}()) = operation(h, "SCORE", args)

"""
op_remove: send native OP REMOVE to the existing `sorted_set` key.
The server applies `sorted_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `member`.
Reference argument example: {"member":{"type":"utf8_string","value":"alpha"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::SortedSetHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
op_range: send native OP RANGE to the existing `sorted_set` key.
The server applies `sorted_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `start`, `stop`, `reverse`.
Reference argument example: {"start":0,"stop":-1,"reverse":false}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_range(h::SortedSetHandle, args = Dict{String,Any}()) = operation(h, "RANGE", args)

"""
SparseVectorHandle: typed facade for the registered `sparse_vector` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct SparseVectorHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
SparseVectorHandle: typed facade for the registered `sparse_vector` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function SparseVectorHandle(c::NativeClient, key::AbstractString)
    return SparseVectorHandle(c, String(key), "sparse_vector")
end

"""
sparse_vector: Provides the sparse vector operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
sparse_vector(c::NativeClient, key::AbstractString) = SparseVectorHandle(c, key)

"""
StreamHandle: typed facade for the registered `stream` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `ADD`, `RANGE`, `GROUP_CREATE`, `GROUP_READ`, `ACK`, `PENDING`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct StreamHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
StreamHandle: send native OP ADD to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `fields`.
Reference argument example: {"fields":{"msg":{"type":"utf8_string","value":"hello"}}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
StreamHandle(c::NativeClient, key::AbstractString) = StreamHandle(c, String(key), "stream")

"""
stream: send native OP ADD to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `fields`.
Reference argument example: {"fields":{"msg":{"type":"utf8_string","value":"hello"}}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
stream(c::NativeClient, key::AbstractString) = StreamHandle(c, key)

"""
op_add: send native OP ADD to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `fields`.
Reference argument example: {"fields":{"msg":{"type":"utf8_string","value":"hello"}}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::StreamHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_range: send native OP RANGE to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `count`.
Reference argument example: {"count":10}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_range(h::StreamHandle, args = Dict{String,Any}()) = operation(h, "RANGE", args)

"""
op_group_create: send native OP GROUP_CREATE to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `group`.
Reference argument example: {"group":"g1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_group_create(h::StreamHandle, args = Dict{String,Any}()) = operation(h, "GROUP_CREATE", args)

"""
op_group_read: send native OP GROUP_READ to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `group`, `consumer`, `count`.
Reference argument example: {"group":"workers","consumer":"c1","count":10}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Timing: Can depend on available data or synchronization state; configure an appropriate request timeout.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_group_read(h::StreamHandle, args = Dict{String,Any}()) = operation(h, "GROUP_READ", args)

"""
op_ack: send native OP ACK to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `group`, `ids`.
Reference argument example: {"group":"workers","ids":["0-1"]}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_ack(h::StreamHandle, args = Dict{String,Any}()) = operation(h, "ACK", args)

"""
op_pending: send native OP PENDING to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `group`.
Reference argument example: {"group":"workers"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_pending(h::StreamHandle, args = Dict{String,Any}()) = operation(h, "PENDING", args)

"""
op_len: send native OP LEN to the existing `stream` key.
The server applies `stream` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::StreamHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
SymbolHandle: typed facade for the registered `symbol` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct SymbolHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
SymbolHandle: typed facade for the registered `symbol` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
SymbolHandle(c::NativeClient, key::AbstractString) = SymbolHandle(c, String(key), "symbol")

"""
symbol: Provides the symbol operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
symbol(c::NativeClient, key::AbstractString) = SymbolHandle(c, key)

"""
TDigestHandle: typed facade for the registered `t_digest` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `compression`.
Supported named operations: `ADD`, `QUANTILE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TDigestHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TDigestHandle: send native OP ADD to the existing `t_digest` key.
The server applies `t_digest` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
TDigestHandle(c::NativeClient, key::AbstractString) = TDigestHandle(c, String(key), "t_digest")

"""
t_digest: send native OP ADD to the existing `t_digest` key.
The server applies `t_digest` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
t_digest(c::NativeClient, key::AbstractString) = TDigestHandle(c, key)

"""
op_add: send native OP ADD to the existing `t_digest` key.
The server applies `t_digest` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":5}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::TDigestHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_quantile: send native OP QUANTILE to the existing `t_digest` key.
The server applies `t_digest` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `q`.
Reference argument example: {"q":0.5}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_quantile(h::TDigestHandle, args = Dict{String,Any}()) = operation(h, "QUANTILE", args)

"""
TagFieldHandle: typed facade for the registered `tag_field` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `name`, `values`.
Supported named operations: `SET`, `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TagFieldHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TagFieldHandle: send native OP SET to the existing `tag_field` key.
The server applies `tag_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `values`.
Reference argument example: {"name":"tags","values":["a","b","c"]}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
TagFieldHandle(c::NativeClient, key::AbstractString) = TagFieldHandle(c, String(key), "tag_field")

"""
tag_field: send native OP SET to the existing `tag_field` key.
The server applies `tag_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `values`.
Reference argument example: {"name":"tags","values":["a","b","c"]}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
tag_field(c::NativeClient, key::AbstractString) = TagFieldHandle(c, key)

"""
op_set: send native OP SET to the existing `tag_field` key.
The server applies `tag_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `values`.
Reference argument example: {"name":"tags","values":["a","b","c"]}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::TagFieldHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `tag_field` key.
The server applies `tag_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::TagFieldHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
TensorHandle: typed facade for the registered `tensor` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `shape`, `dtype`, `data`.
Supported named operations: `GET`, `SET`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TensorHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TensorHandle: send native OP GET to the existing `tensor` key.
The server applies `tensor` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `indices`.
Reference argument example: {"indices":[1,1,1]}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
TensorHandle(c::NativeClient, key::AbstractString) = TensorHandle(c, String(key), "tensor")

"""
tensor: send native OP GET to the existing `tensor` key.
The server applies `tensor` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `indices`.
Reference argument example: {"indices":[1,1,1]}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
tensor(c::NativeClient, key::AbstractString) = TensorHandle(c, key)

"""
op_get: send native OP GET to the existing `tensor` key.
The server applies `tensor` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `indices`.
Reference argument example: {"indices":[1,1,1]}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::TensorHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
op_set: send native OP SET to the existing `tensor` key.
The server applies `tensor` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `indices`, `value`.
Reference argument example: {"indices":[0,0,0],"value":99}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::TensorHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_len: send native OP LEN to the existing `tensor` key.
The server applies `tensor` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::TensorHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
TextFieldHandle: typed facade for the registered `text_field` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `name`, `value`, `weight`.
Supported named operations: `SET`, `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TextFieldHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TextFieldHandle: send native OP SET to the existing `text_field` key.
The server applies `text_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`, `weight`.
Reference argument example: {"name":"body","value":"updated text","weight":2}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function TextFieldHandle(c::NativeClient, key::AbstractString)
    return TextFieldHandle(c, String(key), "text_field")
end

"""
text_field: send native OP SET to the existing `text_field` key.
The server applies `text_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`, `weight`.
Reference argument example: {"name":"body","value":"updated text","weight":2}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
text_field(c::NativeClient, key::AbstractString) = TextFieldHandle(c, key)

"""
op_set: send native OP SET to the existing `text_field` key.
The server applies `text_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `name`, `value`, `weight`.
Reference argument example: {"name":"body","value":"updated text","weight":2}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::TextFieldHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `text_field` key.
The server applies `text_field` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::TextFieldHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
TimeseriesHandle: typed facade for the registered `timeseries` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `labels`, `retention_ms`.
Supported named operations: `ADD`, `LEN`, `RANGE`, `LAST`, `AGGREGATE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TimeseriesHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TimeseriesHandle: send native OP ADD to the existing `timeseries` key.
The server applies `timeseries` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1730000000000,"value":10}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function TimeseriesHandle(c::NativeClient, key::AbstractString)
    return TimeseriesHandle(c, String(key), "timeseries")
end

"""
timeseries: send native OP ADD to the existing `timeseries` key.
The server applies `timeseries` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1730000000000,"value":10}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
timeseries(c::NativeClient, key::AbstractString) = TimeseriesHandle(c, key)

"""
op_add: send native OP ADD to the existing `timeseries` key.
The server applies `timeseries` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `timestamp`, `value`.
Reference argument example: {"timestamp":1730000000000,"value":10}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::TimeseriesHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_len: send native OP LEN to the existing `timeseries` key.
The server applies `timeseries` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::TimeseriesHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_range: send native OP RANGE to the existing `timeseries` key.
The server applies `timeseries` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`.
Reference argument example: {"from":0,"to":3000}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_range(h::TimeseriesHandle, args = Dict{String,Any}()) = operation(h, "RANGE", args)

"""
op_last: send native OP LAST to the existing `timeseries` key.
The server applies `timeseries` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_last(h::TimeseriesHandle, args = Dict{String,Any}()) = operation(h, "LAST", args)

"""
op_aggregate: send native OP AGGREGATE to the existing `timeseries` key.
The server applies `timeseries` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `from`, `to`, `bucket_ms`, `aggregation`.
Reference argument example: {"from":0,"to":3000,"bucket_ms":1000,"aggregation":"avg"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_aggregate(h::TimeseriesHandle, args = Dict{String,Any}()) = operation(h, "AGGREGATE", args)

"""
TimeseriesLabelsHandle: typed facade for the registered `timeseries_labels` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `labels`.
Supported named operations: `SET`, `GET`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TimeseriesLabelsHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TimeseriesLabelsHandle: send native OP SET to the existing `timeseries_labels` key.
The server applies `timeseries_labels` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `label`, `value`.
Reference argument example: {"label":"region","value":"ph"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function TimeseriesLabelsHandle(c::NativeClient, key::AbstractString)
    return TimeseriesLabelsHandle(c, String(key), "timeseries_labels")
end

"""
timeseries_labels: send native OP SET to the existing `timeseries_labels` key.
The server applies `timeseries_labels` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `label`, `value`.
Reference argument example: {"label":"region","value":"ph"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
timeseries_labels(c::NativeClient, key::AbstractString) = TimeseriesLabelsHandle(c, key)

"""
op_set: send native OP SET to the existing `timeseries_labels` key.
The server applies `timeseries_labels` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `label`, `value`.
Reference argument example: {"label":"region","value":"ph"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::TimeseriesLabelsHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `timeseries_labels` key.
The server applies `timeseries_labels` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::TimeseriesLabelsHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
TimestampHandle: typed facade for the registered `timestamp` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TimestampHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TimestampHandle: typed facade for the registered `timestamp` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
TimestampHandle(c::NativeClient, key::AbstractString) = TimestampHandle(c, String(key), "timestamp")

"""
timestamp: Provides the timestamp operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
timestamp(c::NativeClient, key::AbstractString) = TimestampHandle(c, key)

"""
TopKHandle: typed facade for the registered `top_k` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `k`.
Supported named operations: `ADD`, `ITEMS`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TopKHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TopKHandle: send native OP ADD to the existing `top_k` key.
The server applies `top_k` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":"alice","count":10}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
TopKHandle(c::NativeClient, key::AbstractString) = TopKHandle(c, String(key), "top_k")

"""
top_k: send native OP ADD to the existing `top_k` key.
The server applies `top_k` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":"alice","count":10}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
top_k(c::NativeClient, key::AbstractString) = TopKHandle(c, key)

"""
op_add: send native OP ADD to the existing `top_k` key.
The server applies `top_k` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `count`.
Reference argument example: {"value":"alice","count":10}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::TopKHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_items: send native OP ITEMS to the existing `top_k` key.
The server applies `top_k` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_items(h::TopKHandle, args = Dict{String,Any}()) = operation(h, "ITEMS", args)

"""
TrieHandle: typed facade for the registered `trie` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `INSERT`, `PREFIX`, `EXACT`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TrieHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TrieHandle: send native OP INSERT to the existing `trie` key.
The server applies `trie` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"amaquet","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
TrieHandle(c::NativeClient, key::AbstractString) = TrieHandle(c, String(key), "trie")

"""
trie: send native OP INSERT to the existing `trie` key.
The server applies `trie` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"amaquet","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
trie(c::NativeClient, key::AbstractString) = TrieHandle(c, key)

"""
op_insert: send native OP INSERT to the existing `trie` key.
The server applies `trie` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`, `id`.
Reference argument example: {"value":"amaquet","id":"1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_insert(h::TrieHandle, args = Dict{String,Any}()) = operation(h, "INSERT", args)

"""
op_prefix: send native OP PREFIX to the existing `trie` key.
The server applies `trie` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `prefix`, `limit`.
Reference argument example: {"prefix":"ama","limit":10}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_prefix(h::TrieHandle, args = Dict{String,Any}()) = operation(h, "PREFIX", args)

"""
op_exact: send native OP EXACT to the existing `trie` key.
The server applies `trie` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `value`.
Reference argument example: {"value":"amaquet"}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_exact(h::TrieHandle, args = Dict{String,Any}()) = operation(h, "EXACT", args)

"""
TupleHandle: typed facade for the registered `tuple` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `values`.
Supported named operations: `LEN`, `GET`, `VALUES`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct TupleHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
TupleHandle: send native OP LEN to the existing `tuple` key.
The server applies `tuple` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
TupleHandle(c::NativeClient, key::AbstractString) = TupleHandle(c, String(key), "tuple")

"""
tuple_type: construct a typed facade for the registered `tuple` value stored under an Amaquet key.
The server applies `tuple` semantics and validates the operation; this wrapper does not emulate the operation locally.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
tuple_type(c::NativeClient, key::AbstractString) = TupleHandle(c, key)

"""
op_len: send native OP LEN to the existing `tuple` key.
The server applies `tuple` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::TupleHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

"""
op_get: send native OP GET to the existing `tuple` key.
The server applies `tuple` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `index`.
Reference argument example: {"index":0}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::TupleHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
op_values: send native OP VALUES to the existing `tuple` key.
The server applies `tuple` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_values(h::TupleHandle, args = Dict{String,Any}()) = operation(h, "VALUES", args)

"""
UnsignedIntegerHandle: typed facade for the registered `unsigned_integer` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `ADD`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct UnsignedIntegerHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
UnsignedIntegerHandle: send native OP ADD to the existing `unsigned_integer` key.
The server applies `unsigned_integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":8}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function UnsignedIntegerHandle(c::NativeClient, key::AbstractString)
    return UnsignedIntegerHandle(c, String(key), "unsigned_integer")
end

"""
unsigned_integer: send native OP ADD to the existing `unsigned_integer` key.
The server applies `unsigned_integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":8}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
unsigned_integer(c::NativeClient, key::AbstractString) = UnsignedIntegerHandle(c, key)

"""
op_add: send native OP ADD to the existing `unsigned_integer` key.
The server applies `unsigned_integer` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `delta`.
Reference argument example: {"delta":8}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::UnsignedIntegerHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
UrlHandle: typed facade for the registered `url` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: `HOST`, `SCHEME`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct UrlHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
UrlHandle: send native OP HOST to the existing `url` key.
The server applies `url` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
UrlHandle(c::NativeClient, key::AbstractString) = UrlHandle(c, String(key), "url")

"""
url: send native OP HOST to the existing `url` key.
The server applies `url` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
url(c::NativeClient, key::AbstractString) = UrlHandle(c, key)

"""
op_host: send native OP HOST to the existing `url` key.
The server applies `url` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_host(h::UrlHandle, args = Dict{String,Any}()) = operation(h, "HOST", args)

"""
op_scheme: send native OP SCHEME to the existing `url` key.
The server applies `url` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_scheme(h::UrlHandle, args = Dict{String,Any}()) = operation(h, "SCHEME", args)

"""
Utf8StringHandle: typed facade for the registered `utf8_string` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct Utf8StringHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
Utf8StringHandle: typed facade for the registered `utf8_string` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function Utf8StringHandle(c::NativeClient, key::AbstractString)
    return Utf8StringHandle(c, String(key), "utf8_string")
end

"""
utf8_string: Provides the utf8 string operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
utf8_string(c::NativeClient, key::AbstractString) = Utf8StringHandle(c, key)

"""
UuidHandle: typed facade for the registered `uuid` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct UuidHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
UuidHandle: typed facade for the registered `uuid` value stored under an Amaquet key.
Construction command: `SET`. Documented construction option keys: (none).
Supported named operations: (none; use key commands).
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
UuidHandle(c::NativeClient, key::AbstractString) = UuidHandle(c, String(key), "uuid")

"""
uuid: Provides the uuid operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
uuid(c::NativeClient, key::AbstractString) = UuidHandle(c, key)

"""
VectorMetadataHandle: typed facade for the registered `vector_metadata` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: (none).
Supported named operations: `SET`, `GET`, `DELETE`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct VectorMetadataHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
VectorMetadataHandle: send native OP SET to the existing `vector_metadata` key.
The server applies `vector_metadata` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"lang","value":"en"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function VectorMetadataHandle(c::NativeClient, key::AbstractString)
    return VectorMetadataHandle(c, String(key), "vector_metadata")
end

"""
vector_metadata: send native OP SET to the existing `vector_metadata` key.
The server applies `vector_metadata` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"lang","value":"en"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
vector_metadata(c::NativeClient, key::AbstractString) = VectorMetadataHandle(c, key)

"""
op_set: send native OP SET to the existing `vector_metadata` key.
The server applies `vector_metadata` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`, `value`.
Reference argument example: {"field":"lang","value":"en"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_set(h::VectorMetadataHandle, args = Dict{String,Any}()) = operation(h, "SET", args)

"""
op_get: send native OP GET to the existing `vector_metadata` key.
The server applies `vector_metadata` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_get(h::VectorMetadataHandle, args = Dict{String,Any}()) = operation(h, "GET", args)

"""
op_delete: send native OP DELETE to the existing `vector_metadata` key.
The server applies `vector_metadata` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `field`.
Reference argument example: {"field":"lang"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_delete(h::VectorMetadataHandle, args = Dict{String,Any}()) = operation(h, "DELETE", args)

"""
VectorSetHandle: typed facade for the registered `vector_set` value stored under an Amaquet key.
Construction command: `CREATE`. Documented construction option keys: `dim`, `metric`.
Supported named operations: `ADD`, `SEARCH`, `REMOVE`, `LEN`.
The facade forwards requests to the server and does not validate domain-specific arguments before transmission.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
struct VectorSetHandle <: AbstractTypeHandle
    client::NativeClient
    key::String
    wire_type::String
end

"""
VectorSetHandle: send native OP ADD to the existing `vector_set` key.
The server applies `vector_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{"class":"a"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
function VectorSetHandle(c::NativeClient, key::AbstractString)
    return VectorSetHandle(c, String(key), "vector_set")
end

"""
vector_set: send native OP ADD to the existing `vector_set` key.
The server applies `vector_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{"class":"a"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
"""
vector_set(c::NativeClient, key::AbstractString) = VectorSetHandle(c, key)

"""
op_add: send native OP ADD to the existing `vector_set` key.
The server applies `vector_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`, `vector`, `metadata`.
Reference argument example: {"id":"v1","vector":[1,0,0],"metadata":{"class":"a"}}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_add(h::VectorSetHandle, args = Dict{String,Any}()) = operation(h, "ADD", args)

"""
op_search: send native OP SEARCH to the existing `vector_set` key.
The server applies `vector_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `vector`, `k`.
Reference argument example: {"vector":[1,0,0],"k":1}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_search(h::VectorSetHandle, args = Dict{String,Any}()) = operation(h, "SEARCH", args)

"""
op_remove: send native OP REMOVE to the existing `vector_set` key.
The server applies `vector_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: `id`.
Reference argument example: {"id":"v1"}.
Effects: May change server-side state; do not run as a read-only health check.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_remove(h::VectorSetHandle, args = Dict{String,Any}()) = operation(h, "REMOVE", args)

"""
op_len: send native OP LEN to the existing `vector_set` key.
The server applies `vector_set` semantics and validates the operation; this wrapper does not emulate the operation locally.
Documented JSON argument keys: (none for the reference scenario).
Reference argument example: {}.
Effects: No mutation is implied by the operation name; verify the server contract for stateful cases.
Result: Returns or decodes the server response; the result structure is specific to this operation and data type.
Parameter `args`: Exact JSON argument properties supported by the server; names are not translated.
"""
op_len(h::VectorSetHandle, args = Dict{String,Any}()) = operation(h, "LEN", args)

const TYPE_CATALOG = Dict{String,Vector{String}}(
    "adjacency_set" => ["ADD", "NEIGHBORS", "REMOVE"],
    "aggregated_series" => ["AGGREGATE", "RANGE"],
    "array" => ["APPEND", "GET", "LEN", "SET", "VALUES"],
    "atomic_counter" => ["ADD", "CAS", "LOAD"],
    "barrier" => ["WAIT"],
    "big_decimal" => ["ADD", "CMP", "SUB"],
    "big_integer" => ["ADD"],
    "binary_string" => [],
    "bit_field" => ["SET", "GET"],
    "bit_set" => ["SET", "GETBIT", "COUNT"],
    "bitmap" => ["SET", "GETBIT", "COUNT"],
    "blocking_queue" => ["ENQUEUE", "DEQUEUE", "CLOSE", "LEN"],
    "bloom_filter" => ["ADD", "CONTAINS"],
    "boolean" => ["TOGGLE"],
    "bounding_box" => ["CONTAINS"],
    "btree_index" => ["INSERT", "SEARCH", "DELETE", "RANGE"],
    "cbor" => ["GET"],
    "cidr_network" => ["CONTAINS"],
    "consumer_group" => ["SNAPSHOT"],
    "count_min_sketch" => ["ADD", "ESTIMATE"],
    "counter_series" => ["ADD", "LAST", "AGGREGATE", "LEN", "RANGE"],
    "counting_bloom_filter" => ["ADD", "CONTAINS", "REMOVE"],
    "cuckoo_filter" => ["ADD", "CONTAINS", "REMOVE"],
    "decimal" => ["ADD", "CMP", "SUB"],
    "delayed_queue" => ["ENQUEUE", "POP_READY", "LEN"],
    "dense_vector" => ["DISTANCE"],
    "deque" => ["PUSH_BACK", "PUSH_FRONT", "LEN", "POP_FRONT", "POP_BACK", "VALUES"],
    "duration" => ["ADD"],
    "event_log" => ["APPEND", "LEN", "READ"],
    "fifo_queue" => ["ENQUEUE", "PEEK", "DEQUEUE", "LEN"],
    "flat_vector_index" => ["ADD", "SEARCH", "REMOVE", "LEN"],
    "float" => ["ADD"],
    "full_text_document" => ["ADD_TEXT", "ADD_TAG", "ADD_NUMERIC", "SNAPSHOT", "GET"],
    "gauge_series" => ["SET", "LAST", "RANGE", "AGGREGATE", "LEN"],
    "geo_point" => ["DISTANCE"],
    "geo_spatial_index" => ["ADD", "RADIUS", "REMOVE", "BOX", "POLYGON"],
    "geospatial_secondary_index" => ["ADD", "RADIUS", "REMOVE", "BOX", "POLYGON"],
    "hash_index" => ["ADD", "LOOKUP", "REMOVE"],
    "hashmap" => ["SET", "GET", "DELETE", "KEYS"],
    "histogram" => ["OBSERVE", "SNAPSHOT"],
    "hnsw_index" => ["ADD", "SEARCH", "REMOVE"],
    "hyperloglog" => ["ADD", "COUNT"],
    "integer" => ["ADD"],
    "inverted_index" => ["INDEX", "SEARCH", "REMOVE"],
    "json" => ["SET", "GET"],
    "lease" => ["ACQUIRE", "HELD", "RELEASE", "RENEW"],
    "lifo_stack" => ["PUSH", "PEEK", "POP", "LEN"],
    "list" => ["PUSH_BACK", "PUSH_FRONT", "LEN", "RANGE", "POP_FRONT", "POP_BACK"],
    "lock" => ["TRY_LOCK", "UNLOCK", "RENEW"],
    "matrix" => ["GET", "SET", "LEN"],
    "messagepack" => ["GET"],
    "multimap" => ["ADD", "GET", "REMOVE"],
    "multiset" => ["ADD", "COUNT", "REMOVE"],
    "null" => [],
    "numeric_field" => ["SET", "GET"],
    "ordered_map" => ["SET", "GET", "DELETE", "ENTRIES"],
    "ordered_set" => ["ADD", "VALUES", "REMOVE"],
    "persistent_topic" => ["PUBLISH", "READ"],
    "polygon" => ["CONTAINS"],
    "priority_queue" => ["ENQUEUE", "LEN", "DEQUEUE"],
    "pubsub" => ["PUBLISH", "STATS"],
    "quantized_vector" => ["DEQUANTIZE"],
    "radix_tree" => ["INSERT", "PREFIX", "EXACT"],
    "rate_limit_bucket" => ["ALLOW", "REMAINING"],
    "record" => ["SET", "GET"],
    "reliable_queue" => ["ENQUEUE", "CLAIM", "ACK", "NACK", "STATS"],
    "ring_buffer" => ["PUSH", "LEN", "VALUES"],
    "roaring_bitmap" => ["ADD", "CONTAINS", "CARDINALITY", "REMOVE", "VALUES"],
    "secondary_index" => ["ADD", "LOOKUP"],
    "semaphore" => ["TRY_ACQUIRE", "STATS", "RELEASE", "ACQUIRE"],
    "set" => ["ADD", "CONTAINS", "REMOVE", "MEMBERS", "LEN"],
    "sorted_set" => ["ADD", "SCORE", "REMOVE", "RANGE"],
    "sparse_vector" => [],
    "stream" => ["ADD", "RANGE", "GROUP_CREATE", "GROUP_READ", "ACK", "PENDING", "LEN"],
    "symbol" => [],
    "t_digest" => ["ADD", "QUANTILE"],
    "tag_field" => ["SET", "GET"],
    "tensor" => ["GET", "SET", "LEN"],
    "text_field" => ["SET", "GET"],
    "timeseries" => ["ADD", "LEN", "RANGE", "LAST", "AGGREGATE"],
    "timeseries_labels" => ["SET", "GET"],
    "timestamp" => [],
    "top_k" => ["ADD", "ITEMS"],
    "trie" => ["INSERT", "PREFIX", "EXACT"],
    "tuple" => ["LEN", "GET", "VALUES"],
    "unsigned_integer" => ["ADD"],
    "url" => ["HOST", "SCHEME"],
    "utf8_string" => [],
    "uuid" => [],
    "vector_metadata" => ["SET", "GET", "DELETE"],
    "vector_set" => ["ADD", "SEARCH", "REMOVE", "LEN"],
)
const OPERATION_COUNT = 242

"""
typed_handle: Provides the typed handle operation or value as implemented by this Amaquet SDK component; follow the server protocol for accepted arguments.
Parameter `key`: Target Amaquet key; use unique keys for examples and tests.
Failures: Invalid arguments, protocol errors, remote errors, timeout, or connection loss may be reported as appropriate to this API.
"""
function typed_handle(c::NativeClient, type::AbstractString, key::AbstractString)
    name = String(type)
    if name == "adjacency_set"
        return adjacency_set(c, key)
    elseif name == "aggregated_series"
        return aggregated_series(c, key)
    elseif name == "array"
        return array(c, key)
    elseif name == "atomic_counter"
        return atomic_counter(c, key)
    elseif name == "barrier"
        return barrier(c, key)
    elseif name == "big_decimal"
        return big_decimal(c, key)
    elseif name == "big_integer"
        return big_integer(c, key)
    elseif name == "binary_string"
        return binary_string(c, key)
    elseif name == "bit_field"
        return bit_field(c, key)
    elseif name == "bit_set"
        return bit_set(c, key)
    elseif name == "bitmap"
        return bitmap(c, key)
    elseif name == "blocking_queue"
        return blocking_queue(c, key)
    elseif name == "bloom_filter"
        return bloom_filter(c, key)
    elseif name == "boolean"
        return boolean(c, key)
    elseif name == "bounding_box"
        return bounding_box(c, key)
    elseif name == "btree_index"
        return btree_index(c, key)
    elseif name == "cbor"
        return cbor(c, key)
    elseif name == "cidr_network"
        return cidr_network(c, key)
    elseif name == "consumer_group"
        return consumer_group(c, key)
    elseif name == "count_min_sketch"
        return count_min_sketch(c, key)
    elseif name == "counter_series"
        return counter_series(c, key)
    elseif name == "counting_bloom_filter"
        return counting_bloom_filter(c, key)
    elseif name == "cuckoo_filter"
        return cuckoo_filter(c, key)
    elseif name == "decimal"
        return decimal(c, key)
    elseif name == "delayed_queue"
        return delayed_queue(c, key)
    elseif name == "dense_vector"
        return dense_vector(c, key)
    elseif name == "deque"
        return deque(c, key)
    elseif name == "duration"
        return duration(c, key)
    elseif name == "event_log"
        return event_log(c, key)
    elseif name == "fifo_queue"
        return fifo_queue(c, key)
    elseif name == "flat_vector_index"
        return flat_vector_index(c, key)
    elseif name == "float"
        return float(c, key)
    elseif name == "full_text_document"
        return full_text_document(c, key)
    elseif name == "gauge_series"
        return gauge_series(c, key)
    elseif name == "geo_point"
        return geo_point(c, key)
    elseif name == "geo_spatial_index"
        return geo_spatial_index(c, key)
    elseif name == "geospatial_secondary_index"
        return geospatial_secondary_index(c, key)
    elseif name == "hash_index"
        return hash_index(c, key)
    elseif name == "hashmap"
        return hashmap(c, key)
    elseif name == "histogram"
        return histogram(c, key)
    elseif name == "hnsw_index"
        return hnsw_index(c, key)
    elseif name == "hyperloglog"
        return hyperloglog(c, key)
    elseif name == "integer"
        return integer(c, key)
    elseif name == "inverted_index"
        return inverted_index(c, key)
    elseif name == "json"
        return json(c, key)
    elseif name == "lease"
        return lease(c, key)
    elseif name == "lifo_stack"
        return lifo_stack(c, key)
    elseif name == "list"
        return list(c, key)
    elseif name == "lock"
        return lock(c, key)
    elseif name == "matrix"
        return matrix(c, key)
    elseif name == "messagepack"
        return messagepack(c, key)
    elseif name == "multimap"
        return multimap(c, key)
    elseif name == "multiset"
        return multiset(c, key)
    elseif name == "null"
        return null(c, key)
    elseif name == "numeric_field"
        return numeric_field(c, key)
    elseif name == "ordered_map"
        return ordered_map(c, key)
    elseif name == "ordered_set"
        return ordered_set(c, key)
    elseif name == "persistent_topic"
        return persistent_topic(c, key)
    elseif name == "polygon"
        return polygon(c, key)
    elseif name == "priority_queue"
        return priority_queue(c, key)
    elseif name == "pubsub"
        return pubsub(c, key)
    elseif name == "quantized_vector"
        return quantized_vector(c, key)
    elseif name == "radix_tree"
        return radix_tree(c, key)
    elseif name == "rate_limit_bucket"
        return rate_limit_bucket(c, key)
    elseif name == "record"
        return record(c, key)
    elseif name == "reliable_queue"
        return reliable_queue(c, key)
    elseif name == "ring_buffer"
        return ring_buffer(c, key)
    elseif name == "roaring_bitmap"
        return roaring_bitmap(c, key)
    elseif name == "secondary_index"
        return secondary_index(c, key)
    elseif name == "semaphore"
        return semaphore(c, key)
    elseif name == "set"
        return set(c, key)
    elseif name == "sorted_set"
        return sorted_set(c, key)
    elseif name == "sparse_vector"
        return sparse_vector(c, key)
    elseif name == "stream"
        return stream(c, key)
    elseif name == "symbol"
        return symbol(c, key)
    elseif name == "t_digest"
        return t_digest(c, key)
    elseif name == "tag_field"
        return tag_field(c, key)
    elseif name == "tensor"
        return tensor(c, key)
    elseif name == "text_field"
        return text_field(c, key)
    elseif name == "timeseries"
        return timeseries(c, key)
    elseif name == "timeseries_labels"
        return timeseries_labels(c, key)
    elseif name == "timestamp"
        return timestamp(c, key)
    elseif name == "top_k"
        return top_k(c, key)
    elseif name == "trie"
        return trie(c, key)
    elseif name == "tuple"
        return tuple_type(c, key)
    elseif name == "unsigned_integer"
        return unsigned_integer(c, key)
    elseif name == "url"
        return url(c, key)
    elseif name == "utf8_string"
        return utf8_string(c, key)
    elseif name == "uuid"
        return uuid(c, key)
    elseif name == "vector_metadata"
        return vector_metadata(c, key)
    elseif name == "vector_set"
        return vector_set(c, key)
    else
        throw(ArgumentError("unknown Amaquet wire type"))
    end
end
