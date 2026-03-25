## session.nim -- Combined swipl + datalog session.
{.experimental: "strict_funcs".}
import basis/code/choice, bridge, import_facts

type
  HybridSession* = object
    bridge*: Bridge
    importer*: FactImporter
    queries*: int
    imports*: int

proc new_hybrid_session*(query_fn: DatalogQueryFn, assert_fn: PrologAssertFn,
                         datalog_assert_fn: DatalogAssertFn): HybridSession =
  HybridSession(bridge: new_bridge(query_fn, assert_fn),
                importer: new_importer(datalog_assert_fn))

proc query*(s: var HybridSession, predicate: string,
            args: seq[string]): Choice[seq[seq[string]]] =
  inc s.queries
  s.bridge.forward_query(predicate, args)

proc import_fact*(s: var HybridSession, predicate: string,
                  args: seq[string]): Choice[bool] =
  inc s.imports
  s.importer.import_fact(predicate, args)
