{.experimental: "strict_funcs".}
import std/unittest
import swipldatalog

suite "bridge":
  test "forward query":
    let mock_query: DatalogQueryFn = proc(p: string, a: seq[string]): Result[seq[seq[string]], BridgeError] {.raises: [].} =
      Result[seq[seq[string]], BridgeError].good(@[@["alice", "bob"]])
    let mock_assert: PrologAssertFn = proc(t: string): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    var b = new_bridge(mock_query, mock_assert)
    let r = b.forward_query("parent", @["X", "Y"])
    check r.is_good
    check r.val.len == 1
    check b.queries_forwarded == 1

suite "export":
  test "format prolog term":
    check format_prolog_term("parent", @["alice", "bob"]) == "parent(alice, bob)"

  test "format prolog list":
    check format_prolog_list(@["a", "b"]) == "[a, b]"

suite "import":
  test "import fact":
    let mock_assert: DatalogAssertFn = proc(p: string, a: seq[string]): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    var imp = new_importer(mock_assert)
    let r = imp.import_fact("parent", @["alice", "bob"])
    check r.is_good
    check imp.imported == 1

suite "session":
  test "hybrid session":
    let mock_query: DatalogQueryFn = proc(p: string, a: seq[string]): Result[seq[seq[string]], BridgeError] {.raises: [].} =
      Result[seq[seq[string]], BridgeError].good(@[@["result"]])
    let mock_passert: PrologAssertFn = proc(t: string): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    let mock_dassert: DatalogAssertFn = proc(p: string, a: seq[string]): Result[void, BridgeError] {.raises: [].} =
      Result[void, BridgeError](ok: true)
    var s = new_hybrid_session(mock_query, mock_passert, mock_dassert)
    discard s.query("test", @[])
    discard s.import_fact("parent", @["a", "b"])
    check s.queries == 1
    check s.imports == 1
