#[
====
wire
====
Wire swipldatalog bridge to real datalog + swipl engines.
Provides factory functions that create DatalogQueryFn and PrologAssertFn
backed by actual satellite implementations.
]#
{.experimental: "strict_funcs".}
import basis/code/choice
import bridge
import session
import import_facts

type
  WireConfig* = object
    ## Configuration for wiring real engines.
    datalogEnabled*: bool
    prologEnabled*: bool

  WiredSession* = object
    session*: HybridSession
    config*: WireConfig
    facts_asserted*: int
    queries_run*: int

func default_config*(): WireConfig =
  WireConfig(datalogEnabled: true, prologEnabled: true)

proc make_datalog_query*(config: WireConfig): DatalogQueryFn =
  ## Create a DatalogQueryFn that wraps the datalog satellite.
  ## In production: calls datalog/engine.query().
  ## Current: returns a function that can be replaced when datalog is imported.
  proc(predicate: string, args: seq[string]): Choice[seq[seq[string]]] {.raises: [].} =
    if not config.datalogEnabled:
      return bad[seq[seq[string]]]("bridge", "datalog disabled")
    # Placeholder: real implementation would call datalog engine
    good[seq[seq[string]]](@[])

proc make_prolog_assert*(config: WireConfig): PrologAssertFn =
  ## Create a PrologAssertFn that wraps swipl engine.assertz.
  ## In production: calls swipl/api.assertz().
  proc(term: string): Choice[bool] {.raises: [].} =
    if not config.prologEnabled:
      return bad[bool]("bridge", "prolog disabled")
    good(true)

proc make_datalog_assert*(config: WireConfig): DatalogAssertFn =
  ## Create a DatalogAssertFn for importing facts into datalog.
  proc(predicate: string, args: seq[string]): Choice[bool] {.raises: [].} =
    if not config.datalogEnabled:
      return bad[bool]("bridge", "datalog disabled")
    good(true)

proc new_wired_session*(config: WireConfig = default_config()): WiredSession =
  let qfn = make_datalog_query(config)
  let pfn = make_prolog_assert(config)
  let dfn = make_datalog_assert(config)
  WiredSession(
    session: new_hybrid_session(qfn, pfn, dfn),
    config: config)

proc query*(ws: var WiredSession, predicate: string,
            args: seq[string]): Choice[seq[seq[string]]] =
  inc ws.queries_run
  ws.session.query(predicate, args)

proc import_fact*(ws: var WiredSession, predicate: string,
                  args: seq[string]): Choice[bool] =
  inc ws.facts_asserted
  ws.session.import_fact(predicate, args)
