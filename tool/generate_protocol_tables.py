# -*- coding: utf-8 -*-
"""Emit lib/features/exercise/protocols/protocol_tables.dart from the parsed
protocol document.

Run after tool/parse_protocols.py:

    python tool/parse_protocols.py tool/protocols.json
    python tool/generate_protocol_tables.py tool/protocols.json

The tables are generated rather than typed because they carry roughly 420
prescription values, every one of which is a hold time or a rep count for a
patient. A mistyped number here is a clinical error, not a cosmetic one.
"""
import json, sys

# Document heading -> (dart id, IPAQActivityLevel, intensity, time, type)
CORE = "PFMT + core + functional + dynamic strengthening"
META = {
    "Mild Incontinence + High Activity":
        ("mild_high", "high", "moderate to high", "20-30 mins", CORE),
    "Mild Incontinence + Moderate Activity":
        ("mild_moderate", "moderate", "moderate", "20-30 mins", CORE),
    "Mild Incontinence + Low Activity":
        ("mild_low", "low", "moderate to high", "20-30 mins", CORE),
    "Moderate Incontinence + High Activity":
        ("moderate_high", "high", "moderate to high", "20-30 mins", CORE),
    "Moderate Incontinence + Moderate Activity":
        ("moderate_moderate", "moderate", "moderate", "20-30 mins", CORE),
    "Moderate Incontinence + Low Activity":
        ("moderate_low", "low", "moderate to high", "20-30 mins", CORE),
    "Severe Incontinence + High Activity":
        ("severe", "high", "low to moderate", "15-20 mins",
         "PFMT + core strengthening"),
}
ORDER = ["mild_high", "mild_moderate", "mild_low", "moderate_high",
         "moderate_moderate", "moderate_low", "severe"]

HEADER = '''// GENERATED FILE - DO NOT EDIT BY HAND.
//
// Transcribed from "App protocols with description.docx" by
// tool/generate_protocol_tables.py. To change a prescription, change the
// document, re-run tool/parse_protocols.py and then this generator, and check
// that test/protocol_tables_test.dart still passes - it pins the days-per-week
// and items-per-day of every protocol against the document.
//
// The document defines seven of the nine severity x activity cells. It has no
// table for Severe+Moderate or Severe+Low, so all three severe cells share the
// one severe protocol, which is already the most conservative here.

import '../../assessment/models/ipaq_model.dart';
import '../models/protocol.dart';

'''

def dart_item(it):
    parts = ["exerciseKey: '%s'" % it["key"], "sets: %d" % it["sets"]]
    if it.get("position"):
        parts.append("position: ExercisePosition.%s" % it["position"])
    if it.get("reps") is not None and it["key"] != "diaphragmatic_breathing":
        parts.append("reps: %d" % it["reps"])
    if it.get("hold") is not None:
        parts.append("holdSeconds: %d" % it["hold"])
    if it.get("relax") is not None:
        parts.append("relaxSeconds: %d" % it["relax"])
    return "        PrescribedItem(%s)," % ", ".join(parts)

def main(path):
    data = json.load(open(path, encoding="utf-8"))
    by_id = {}
    for name, p in data.items():
        if name not in META:
            raise SystemExit("unknown protocol heading: %r" % name)
        by_id[META[name][0]] = (META[name], p)

    out = [HEADER, "/// Every protocol the document defines, in document order.\n",
           "const List<Protocol> allProtocols = [\n"]
    for pid in ORDER:
        (_, activity, intensity, time, ptype), p = by_id[pid]
        out.append("  Protocol(\n")
        out.append("    id: '%s',\n" % pid)
        out.append("    severityBand: '%s',\n" % pid.split("_")[0])
        out.append("    activity: IPAQActivityLevel.%s,\n" % activity)
        out.append("    intensity: '%s',\n" % intensity)
        out.append("    timeRange: '%s',\n" % time)
        out.append("    type: '%s',\n" % ptype)
        out.append("    blocks: [\n")
        for b in p["blocks"]:
            out.append("      ProtocolWeekBlock(\n")
            out.append("        startWeek: %d,\n" % b["startWeek"])
            out.append("        endWeek: %d,\n" % b["endWeek"])
            out.append("        daysPerWeek: %d,\n" % b["daysPerWeek"])
            out.append("        progressionFocus: '%s',\n" % b["focus"])
            out.append("        items: [\n")
            for it in b["items"]:
                out.append(dart_item(it).replace("        P", "          P") + "\n")
            out.append("        ],\n")
            out.append("      ),\n")
        out.append("    ],\n")
        out.append("  ),\n")
    out.append("];\n")

    dest = "lib/features/exercise/protocols/protocol_tables.dart"
    open(dest, "w", encoding="utf-8", newline="\n").write("".join(out))
    total = sum(len(b["items"]) for _, p in by_id.values() for b in p["blocks"])
    print("wrote %s: %d protocols, %d prescribed items" % (dest, len(ORDER), total))

main(sys.argv[1])
