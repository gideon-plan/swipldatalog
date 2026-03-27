{.experimental: "strict_funcs".}
import std/unittest
import basis/code/choice
import swipldatalog/wire

suite "Wired session":
  test "create wired session":
    var ws = new_wired_session()
    check ws.config.datalogEnabled
    check ws.config.prologEnabled
  test "query through wire":
    var ws = new_wired_session()
    let r = ws.query("test", @["a"])
    check r.is_good
    check ws.queries_run == 1
  test "import fact through wire":
    var ws = new_wired_session()
    let r = ws.import_fact("parent", @["alice", "bob"])
    check r.is_good
    check ws.facts_asserted == 1
  test "disabled datalog":
    var ws = new_wired_session(WireConfig(datalogEnabled: false, prologEnabled: true))
    let r = ws.query("test", @[])
    check not r.is_good
