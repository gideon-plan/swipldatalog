## export_results.nim -- Export datalog results as Prolog terms.
{.experimental: "strict_funcs".}
import std/strutils

proc format_prolog_term*(predicate: string, args: seq[string]): string =
  predicate & "(" & args.join(", ") & ")"

proc format_prolog_list*(terms: seq[string]): string =
  "[" & terms.join(", ") & "]"

proc results_to_prolog*(predicate: string, results: seq[seq[string]]): seq[string] =
  for row in results:
    result.add(format_prolog_term(predicate, row))
