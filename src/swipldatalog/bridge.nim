## bridge.nim -- Register datalog predicates as SWI-Prolog foreign predicates.
{.experimental: "strict_funcs".}
import basis/code/choice

type
  BridgeError* = object of CatchableError


type
  DatalogQueryFn* = proc(predicate: string, args: seq[string]): Choice[seq[seq[string]]] {.raises: [].}
  PrologAssertFn* = proc(term: string): Choice[bool] {.raises: [].}

  Bridge* = object
    query_fn*: DatalogQueryFn
    assert_fn*: PrologAssertFn
    queries_forwarded*: int

proc new_bridge*(query_fn: DatalogQueryFn, assert_fn: PrologAssertFn): Bridge =
  Bridge(query_fn: query_fn, assert_fn: assert_fn)

proc forward_query*(b: var Bridge, predicate: string,
                    args: seq[string]): Choice[seq[seq[string]]] =
  inc b.queries_forwarded
  b.query_fn(predicate, args)
