## swipldatalog.nim -- SWI-Prolog + Datalog hybrid logic. Re-export module.
{.experimental: "strict_funcs".}
import swipldatalog/[bridge, import_facts, export_results, session, lattice]
export bridge, import_facts, export_results, session, lattice
