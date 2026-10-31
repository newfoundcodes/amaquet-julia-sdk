<div align="center">
  <img src="https://amaquet.newfoundcodes.com/amaquet.png" width="128" />
  <h1>Amaquet Julia SDK</h1>
  <p>
    <a href="https://github.com/newfoundcodes/amaquet-julia-sdk/actions"><img src="https://github.com/newfoundcodes/amaquet-julia-sdk/actions/workflows/ci.yml/badge.svg" alt="Build Status"></a>
  </p>
</div>

Standalone Julia 1.10+ package for the Amaquet native TCP/TLS protocol and separate HTTP(S) administration API. The SDK is implemented in Julia and does not use an intermediate SDK service, Redis/RESP, or a Go bridge.

## Prerequisites

- Julia 1.10 or newer
- `JSON.jl` 1.x and `MbedTLS.jl` 1.x (resolved by Julia Pkg)
- Native `libsodium` installed and discoverable when connecting to an Amaquet server that advertises a signed Ed25519 identity; missing cryptography support **fails closed**. The caller can require a fingerprint or public key pin. On Debian/Ubuntu: `sudo apt-get install libsodium23`. On macOS: `brew install libsodium`.
- For native TLS, the server must present a certificate chain trusted by the client's CA store and a certificate matching the endpoint hostname. This SDK does not provide an insecure TLS bypass.

## Install from source

```bash
unzip amaquet-julia-sdk.zip
cd amaquet-julia-sdk
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
julia --project=. -e 'using Amaquet; println(length(Amaquet.TYPE_CATALOG))'
```

Use from another Julia application:

```julia
using Pkg
Pkg.develop(path="../amaquet-julia-sdk")
```

## First connection

```julia
using Amaquet

client = connect("amaquet://127.0.0.1:13378";
                 api_key=get(ENV, "AMAQUET_API_KEY", nothing),
                 timeout=10)
try
    @show ping(client)  # "PONG"
    set!(client, "sample:user", "utf8_string", "hello")
    @show get(client, "sample:user")
    @show typeofkey(client, "sample:user")
    delete!(client, "sample:user")
finally
    close!(client)
end
```

**Encrypted deployment:**

```julia
client = connect("amaquets://db.example.com:13378";
    api_key=ENV["AMAQUET_API_KEY"],
    require_identity=true,
    identity_fingerprint=ENV["AMAQUET_SERVER_FINGERPRINT"])
```

The fingerprint must come from a trusted configuration channel and has the server format `ed25519:<64 lowercase SHA-256 hex characters>`. The SDK compares it to the server public key and verifies the Ed25519 signature on a fresh HELLO nonce. TLS endpoint credentials must be configured separately; the URI parser intentionally rejects embedded credentials, paths, and query strings.

## Typed operations

```julia
c = connect("amaquet://127.0.0.1:13378"; api_key=get(ENV,"AMAQUET_API_KEY",nothing))
try
    counter = Amaquet.atomic_counter(c, "counter:julia")
    create!(counter; options=Dict("initial" => 10))
    println(Amaquet.op_add(counter, Dict("delta" => 5)))
    println(Amaquet.op_load(counter))
    println(snapshot(counter))
finally
    close!(c)
end
```

Julia uses a shared function namespace, so type operation methods have an `op_` prefix. For example, wire `PUSH_BACK` maps to `Amaquet.op_push_back(handle, args)`. Call `operation(client, key, "PUSH_BACK", args)` or `operation(handle, name, args)` for dynamic names. All server operation arguments remain unchanged. Type constructors such as `Amaquet.atomic_counter(client, key)` use the Go source's wire names.

The creation mode is type dependent: 69 documented scenarios use `CREATE` and 22 use `SET`. Read the fixture for each type at `test/fixtures/<type>.json`, or use its runnable example under `examples/types/`.

### Registered wire types and operations

The following catalog lists the 91 registered wire types, their Julia handle factories, and their type-specific operations. Operation names use the lowercase `op_*` form in Julia.

| Wire type | Julia handle factory | Operations (`op_*`) |
|---|---|---|
| `adjacency_set` | `Amaquet.adjacency_set(client,key)` | `op_add`, `op_neighbors`, `op_remove` |
| `aggregated_series` | `Amaquet.aggregated_series(client,key)` | `op_aggregate`, `op_range` |
| `array` | `Amaquet.array(client,key)` | `op_append`, `op_get`, `op_len`, `op_set`, `op_values` |
| `atomic_counter` | `Amaquet.atomic_counter(client,key)` | `op_add`, `op_cas`, `op_load` |
| `barrier` | `Amaquet.barrier(client,key)` | `op_wait` |
| `big_decimal` | `Amaquet.big_decimal(client,key)` | `op_add`, `op_cmp`, `op_sub` |
| `big_integer` | `Amaquet.big_integer(client,key)` | `op_add` |
| `binary_string` | `Amaquet.binary_string(client,key)` | Direct value / no type-specific `OP` |
| `bit_field` | `Amaquet.bit_field(client,key)` | `op_set`, `op_get` |
| `bit_set` | `Amaquet.bit_set(client,key)` | `op_set`, `op_getbit`, `op_count` |
| `bitmap` | `Amaquet.bitmap(client,key)` | `op_set`, `op_getbit`, `op_count` |
| `blocking_queue` | `Amaquet.blocking_queue(client,key)` | `op_enqueue`, `op_dequeue`, `op_close`, `op_len` |
| `bloom_filter` | `Amaquet.bloom_filter(client,key)` | `op_add`, `op_contains` |
| `boolean` | `Amaquet.boolean(client,key)` | `op_toggle` |
| `bounding_box` | `Amaquet.bounding_box(client,key)` | `op_contains` |
| `btree_index` | `Amaquet.btree_index(client,key)` | `op_insert`, `op_search`, `op_delete`, `op_range` |
| `cbor` | `Amaquet.cbor(client,key)` | `op_get` |
| `cidr_network` | `Amaquet.cidr_network(client,key)` | `op_contains` |
| `consumer_group` | `Amaquet.consumer_group(client,key)` | `op_snapshot` |
| `count_min_sketch` | `Amaquet.count_min_sketch(client,key)` | `op_add`, `op_estimate` |
| `counter_series` | `Amaquet.counter_series(client,key)` | `op_add`, `op_last`, `op_aggregate`, `op_len`, `op_range` |
| `counting_bloom_filter` | `Amaquet.counting_bloom_filter(client,key)` | `op_add`, `op_contains`, `op_remove` |
| `cuckoo_filter` | `Amaquet.cuckoo_filter(client,key)` | `op_add`, `op_contains`, `op_remove` |
| `decimal` | `Amaquet.decimal(client,key)` | `op_add`, `op_cmp`, `op_sub` |
| `delayed_queue` | `Amaquet.delayed_queue(client,key)` | `op_enqueue`, `op_pop_ready`, `op_len` |
| `dense_vector` | `Amaquet.dense_vector(client,key)` | `op_distance` |
| `deque` | `Amaquet.deque(client,key)` | `op_push_back`, `op_push_front`, `op_len`, `op_pop_front`, `op_pop_back`, `op_values` |
| `duration` | `Amaquet.duration(client,key)` | `op_add` |
| `event_log` | `Amaquet.event_log(client,key)` | `op_append`, `op_len`, `op_read` |
| `fifo_queue` | `Amaquet.fifo_queue(client,key)` | `op_enqueue`, `op_peek`, `op_dequeue`, `op_len` |
| `flat_vector_index` | `Amaquet.flat_vector_index(client,key)` | `op_add`, `op_search`, `op_remove`, `op_len` |
| `float` | `Amaquet.float(client,key)` | `op_add` |
| `full_text_document` | `Amaquet.full_text_document(client,key)` | `op_add_text`, `op_add_tag`, `op_add_numeric`, `op_snapshot`, `op_get` |
| `gauge_series` | `Amaquet.gauge_series(client,key)` | `op_set`, `op_last`, `op_range`, `op_aggregate`, `op_len` |
| `geo_point` | `Amaquet.geo_point(client,key)` | `op_distance` |
| `geo_spatial_index` | `Amaquet.geo_spatial_index(client,key)` | `op_add`, `op_radius`, `op_remove`, `op_box`, `op_polygon` |
| `geospatial_secondary_index` | `Amaquet.geospatial_secondary_index(client,key)` | `op_add`, `op_radius`, `op_remove`, `op_box`, `op_polygon` |
| `hash_index` | `Amaquet.hash_index(client,key)` | `op_add`, `op_lookup`, `op_remove` |
| `hashmap` | `Amaquet.hashmap(client,key)` | `op_set`, `op_get`, `op_delete`, `op_keys` |
| `histogram` | `Amaquet.histogram(client,key)` | `op_observe`, `op_snapshot` |
| `hnsw_index` | `Amaquet.hnsw_index(client,key)` | `op_add`, `op_search`, `op_remove` |
| `hyperloglog` | `Amaquet.hyperloglog(client,key)` | `op_add`, `op_count` |
| `integer` | `Amaquet.integer(client,key)` | `op_add` |
| `inverted_index` | `Amaquet.inverted_index(client,key)` | `op_index`, `op_search`, `op_remove` |
| `json` | `Amaquet.json(client,key)` | `op_set`, `op_get` |
| `lease` | `Amaquet.lease(client,key)` | `op_acquire`, `op_held`, `op_release`, `op_renew` |
| `lifo_stack` | `Amaquet.lifo_stack(client,key)` | `op_push`, `op_peek`, `op_pop`, `op_len` |
| `list` | `Amaquet.list(client,key)` | `op_push_back`, `op_push_front`, `op_len`, `op_range`, `op_pop_front`, `op_pop_back` |
| `lock` | `Amaquet.lock(client,key)` | `op_try_lock`, `op_unlock`, `op_renew` |
| `matrix` | `Amaquet.matrix(client,key)` | `op_get`, `op_set`, `op_len` |
| `messagepack` | `Amaquet.messagepack(client,key)` | `op_get` |
| `multimap` | `Amaquet.multimap(client,key)` | `op_add`, `op_get`, `op_remove` |
| `multiset` | `Amaquet.multiset(client,key)` | `op_add`, `op_count`, `op_remove` |
| `null` | `Amaquet.null(client,key)` | Direct value / no type-specific `OP` |
| `numeric_field` | `Amaquet.numeric_field(client,key)` | `op_set`, `op_get` |
| `ordered_map` | `Amaquet.ordered_map(client,key)` | `op_set`, `op_get`, `op_delete`, `op_entries` |
| `ordered_set` | `Amaquet.ordered_set(client,key)` | `op_add`, `op_values`, `op_remove` |
| `persistent_topic` | `Amaquet.persistent_topic(client,key)` | `op_publish`, `op_read` |
| `polygon` | `Amaquet.polygon(client,key)` | `op_contains` |
| `priority_queue` | `Amaquet.priority_queue(client,key)` | `op_enqueue`, `op_len`, `op_dequeue` |
| `pubsub` | `Amaquet.pubsub(client,key)` | `op_publish`, `op_stats` |
| `quantized_vector` | `Amaquet.quantized_vector(client,key)` | `op_dequantize` |
| `radix_tree` | `Amaquet.radix_tree(client,key)` | `op_insert`, `op_prefix`, `op_exact` |
| `rate_limit_bucket` | `Amaquet.rate_limit_bucket(client,key)` | `op_allow`, `op_remaining` |
| `record` | `Amaquet.record(client,key)` | `op_set`, `op_get` |
| `reliable_queue` | `Amaquet.reliable_queue(client,key)` | `op_enqueue`, `op_claim`, `op_ack`, `op_nack`, `op_stats` |
| `ring_buffer` | `Amaquet.ring_buffer(client,key)` | `op_push`, `op_len`, `op_values` |
| `roaring_bitmap` | `Amaquet.roaring_bitmap(client,key)` | `op_add`, `op_contains`, `op_cardinality`, `op_remove`, `op_values` |
| `secondary_index` | `Amaquet.secondary_index(client,key)` | `op_add`, `op_lookup` |
| `semaphore` | `Amaquet.semaphore(client,key)` | `op_try_acquire`, `op_stats`, `op_release`, `op_acquire` |
| `set` | `Amaquet.set(client,key)` | `op_add`, `op_contains`, `op_remove`, `op_members`, `op_len` |
| `sorted_set` | `Amaquet.sorted_set(client,key)` | `op_add`, `op_score`, `op_remove`, `op_range` |
| `sparse_vector` | `Amaquet.sparse_vector(client,key)` | Direct value / no type-specific `OP` |
| `stream` | `Amaquet.stream(client,key)` | `op_add`, `op_range`, `op_group_create`, `op_group_read`, `op_ack`, `op_pending`, `op_len` |
| `symbol` | `Amaquet.symbol(client,key)` | Direct value / no type-specific `OP` |
| `t_digest` | `Amaquet.t_digest(client,key)` | `op_add`, `op_quantile` |
| `tag_field` | `Amaquet.tag_field(client,key)` | `op_set`, `op_get` |
| `tensor` | `Amaquet.tensor(client,key)` | `op_get`, `op_set`, `op_len` |
| `text_field` | `Amaquet.text_field(client,key)` | `op_set`, `op_get` |
| `timeseries` | `Amaquet.timeseries(client,key)` | `op_add`, `op_len`, `op_range`, `op_last`, `op_aggregate` |
| `timeseries_labels` | `Amaquet.timeseries_labels(client,key)` | `op_set`, `op_get` |
| `timestamp` | `Amaquet.timestamp(client,key)` | Direct value / no type-specific `OP` |
| `top_k` | `Amaquet.top_k(client,key)` | `op_add`, `op_items` |
| `trie` | `Amaquet.trie(client,key)` | `op_insert`, `op_prefix`, `op_exact` |
| `tuple` | `Amaquet.tuple_type(client,key)` | `op_len`, `op_get`, `op_values` |
| `unsigned_integer` | `Amaquet.unsigned_integer(client,key)` | `op_add` |
| `url` | `Amaquet.url(client,key)` | `op_host`, `op_scheme` |
| `utf8_string` | `Amaquet.utf8_string(client,key)` | Direct value / no type-specific `OP` |
| `uuid` | `Amaquet.uuid(client,key)` | Direct value / no type-specific `OP` |
| `vector_metadata` | `Amaquet.vector_metadata(client,key)` | `op_set`, `op_get`, `op_delete` |
| `vector_set` | `Amaquet.vector_set(client,key)` | `op_add`, `op_search`, `op_remove`, `op_len` |

## Native commands and exact numbers

The 23 server commands have named wrappers plus `command(client, "NAME", args)` for direct access. `batch!(client, requests)` uses the server-required `requests` field. `cas!(client, key, expected_version, wire_type, value)` uses `expected_version`. Use `BigInt` and decimal strings when the wire type requires them; do not convert large integers or financial decimals to `Float64`.

```julia
big_value = parse(BigInt, "184467440737095516160")
request = Dict("command"=>"SET", "args"=>Dict("key"=>"large", "type"=>"big_integer", "value"=>string(big_value)))
command(c, request["command"], request["args"])
```

`JSON.jl` version 1 is required to preserve arbitrary-precision numeric literals when parsing. Preserve the string representation for direct `big_integer`/`decimal` wire types where the server expects a string.

## Requests, cancellation, subscriptions, and pools

```julia
id, ch = submit(c, 1, Dict("command" => "PING", "args" => Dict()))
println(await_response(c, id, ch; timeout=5))
# cancel!(c, id) sends protocol opcode 6 and reports whether cancellation succeeded.

# First create a pubsub key using create!(c, key, "pubsub").
sub = subscribe!(c, "bus", "events"; buffer=64)
try
    event = poll!(sub; timeout=2)  # returns nothing on timeout
    println(event)
    println("Events dropped due to queue overflow: ", dropped(sub))
finally
    unsubscribe!(c, sub)
end

pool = ConnectionPool("amaquet://127.0.0.1:13378";
                      size=4, api_key=get(ENV,"AMAQUET_API_KEY",nothing))
try
    with_client(pool) do c
        println(ping(c))
    end
finally
    close!(pool)
end
```

A single I/O task reads incoming frames, routes responses by 64-bit request IDs, and appends events to bounded queues. Timeout cleanup releases pending requests and schedules a CANCEL frame. Subscriptions use a drop-oldest policy to protect memory. A pool will not reuse connections with pending requests or active subscriptions.

## Chunked blob transfer

The source implementation requires `upload_id` on `BLOB_BEGIN`; this SDK generates a cryptographically random 128-bit hex ID by default. Uploads can be connection-scoped. Each request uses Base64 chunk content in JSON. Server limits are 1 GiB total, 32 MiB per read, and 64 MiB per frame. The default upload chunk is 512 KiB to stay comfortably below the frame limit.

```julia
payload = rand(UInt8, 2 * 1024 * 1024)
upload_blob!(c, "binary:julia", payload)
@assert download_blob!(c, "binary:julia") == payload

upload_file!(c, "binary:file", "/tmp/payload.bin")
download_file!(c, "binary:file", "/tmp/result.bin")
```

`upload_file!` and `download_file!` stream an `IO` or a file path; uploads abort staged blobs after an exception. The download detects a changed object version or size between chunks. As the source server does not guarantee an atomic multi-request snapshot, concurrent writes should be excluded or retried.

## Security model

- Native TLS is enabled by `amaquets://`. The client requests X.509 certificate-chain and hostname verification through MbedTLS and does not provide an insecure TLS bypass.
- Each connection receives a fresh HELLO nonce. If the server advertises a signed identity, its detached Ed25519 signature must verify. A configured public-key or fingerprint pin, or `require_identity=true`, fails closed when identity data is absent or invalid. The fingerprint is SHA-256 of the 32-byte raw public key, prefixed with `ed25519:`.
- Ed25519 verification uses dynamically loaded `libsodium`; missing cryptography support rejects connections when verification is required.
- API keys are sent in native `AUTH` payloads rather than URLs, but plaintext `amaquet://` can expose them. Use `amaquets://` on untrusted networks.
- HTTP credentials require HTTPS outside loopback unless an explicit insecure-credential override is passed. Redirects are not followed, and HTTP response bodies and native frames are bounded before allocation.
- Pending requests and Pub/Sub queues are bounded. Slow application code does not block the socket reader, but subscriptions, staged uploads, and connection-scoped data still need cleanup when connections close.
- The SDK does not automatically retry failed writes because an unacknowledged mutation may already have executed.

## HTTP administration

```julia
a = AdminClient("http://127.0.0.1:13379";
    bearer_token=get(ENV, "AMAQUET_ADMIN_TOKEN", nothing))
@show Amaquet.get_health(a)
@show Amaquet.get_overview(a)
@show Amaquet.list_data_keys(a; query=Dict("prefix"=>"sample:"))
@show Amaquet.get_metrics(a) # Prometheus text
```

Control plane uses HTTP(S), not the native TCP protocol. The HTTP client rejects redirects, percent-encodes query values and path IDs, applies a bounded response buffer, and refuses transmitting credentials over plaintext HTTP to non-loopback destinations unless explicitly opted in. Supported authentication includes `Authorization: Bearer`, `X-Amaquet-Admin-Token`, and the server's session cookie.

### HTTP administration method inventory

Administration listens on a distinct HTTP(S) port. For `{id}` methods, pass the resource ID as the next positional argument; the SDK percent-encodes it. For query parameters use `query=Dict("key"=>"value")`; for request JSON use `body=Dict(...)`.

| Method | Path | Julia wrapper |
|---|---|---|
| `GET` | `/openapi.json` | `Amaquet.get_open_api(admin,...)` |
| `GET` | `/api/health` | `Amaquet.get_health(admin,...)` |
| `GET` | `/api/ready` | `Amaquet.get_readiness(admin,...)` |
| `GET` | `/metrics` | `Amaquet.get_metrics(admin,...)` |
| `GET` | `/api/auth/check` | `Amaquet.check_authentication(admin,...)` |
| `POST` | `/api/session` | `Amaquet.create_session(admin,...)` |
| `DELETE` | `/api/session` | `Amaquet.delete_session(admin,...)` |
| `POST` | `/api/identity/accept-invite` | `Amaquet.accept_member_invite(admin,...)` |
| `POST` | `/api/identity/mfa` | `Amaquet.begin_member_mfa(admin,...)` |
| `PUT` | `/api/identity/mfa` | `Amaquet.confirm_member_mfa(admin,...)` |
| `DELETE` | `/api/identity/mfa` | `Amaquet.disable_member_mfa(admin,...)` |
| `GET` | `/api/overview` | `Amaquet.get_overview(admin,...)` |
| `GET` | `/api/organization` | `Amaquet.get_organization(admin,...)` |
| `PUT` | `/api/organization` | `Amaquet.update_organization(admin,...)` |
| `GET` | `/api/members` | `Amaquet.list_members(admin,...)` |
| `POST` | `/api/members` | `Amaquet.create_member(admin,...)` |
| `PATCH` | `/api/members/{id}` | `Amaquet.update_member(admin,...)` |
| `DELETE` | `/api/members/{id}` | `Amaquet.delete_member(admin,...)` |
| `POST` | `/api/members/{id}/invite` | `Amaquet.create_member_invite(admin,...)` |
| `GET` | `/api/rbac` | `Amaquet.get_rbac(admin,...)` |
| `PUT` | `/api/rbac` | `Amaquet.update_rbac(admin,...)` |
| `GET` | `/api/api-keys` | `Amaquet.list_apikeys(admin,...)` |
| `POST` | `/api/api-keys` | `Amaquet.create_apikey(admin,...)` |
| `DELETE` | `/api/api-keys/{id}` | `Amaquet.revoke_apikey(admin,...)` |
| `GET` | `/api/system` | `Amaquet.get_system_configuration(admin,...)` |
| `PUT` | `/api/system` | `Amaquet.update_system_configuration(admin,...)` |
| `POST` | `/api/persistence/checkpoint` | `Amaquet.create_persistence_checkpoint(admin,...)` |
| `POST` | `/api/persistence/compact` | `Amaquet.compact_persistence(admin,...)` |
| `GET` | `/api/data/keys` | `Amaquet.list_data_keys(admin,...)` |
| `GET` | `/api/data/key` | `Amaquet.get_data_key(admin,...)` |
| `DELETE` | `/api/data/key` | `Amaquet.delete_data_key(admin,...)` |
| `POST` | `/api/data/command` | `Amaquet.execute_data_command(admin,...)` |
| `GET` | `/api/audit` | `Amaquet.list_audit_events(admin,...)` |

## Constraints and error types

- `ProtocolError`: invalid frame, timeout, unsupported protocol, transport framing or response size.
- `SecurityError`: identity/credential/TLS-policy errors. TLS handshake errors from MbedTLS can also propagate.
- `ServerError(code, message)`: server error envelope or HTTP status.
- `ClientClosedError`: a transport or pool that has closed.
- No hidden reconnect or automatic retries of writes. A retry can duplicate a mutation.
- No automatic cross-request transaction for streamed blobs or batch operations.
- No browser/WebSocket transport (Julia SDK is intended for native applications and services).

## License

Amaquet Julia SDK is licensed under the MIT License. See [LICENSE](LICENSE).
