## import_facts.nim -- Import Prolog facts into datalog database.
{.experimental: "strict_funcs".}
import basis/code/choice

type
  DatalogAssertFn* = proc(predicate: string, args: seq[string]): Choice[bool] {.raises: [].}

  FactImporter* = object
    assert_fn*: DatalogAssertFn
    imported*: int

proc new_importer*(fn: DatalogAssertFn): FactImporter =
  FactImporter(assert_fn: fn)

proc import_fact*(imp: var FactImporter, predicate: string,
                  args: seq[string]): Choice[bool] =
  let r = imp.assert_fn(predicate, args)
  if r.is_good: inc imp.imported
  r
