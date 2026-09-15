# -*- coding: utf-8 -*-
"""Parse the protocol tables out of the extracted .docx text into JSON."""
import re, json, sys

SRC = r"C:/Users/tarun/AppData/Local/Temp/claude/C--Tarun-College-Projects-RV-PHYSIO/72d9ac39-9dc0-4f7d-8a97-13e00eaf34ca/scratchpad/protocols.txt"

# canonical exercise keys, longest names first so 'Straight leg raise' wins over 'leg raise'
EX = [
    ("Diaphragmatic breathing exercise", "diaphragmatic_breathing"),
    ("Quadruped arm-leg raise",          "quadruped_arm_leg_raise"),
    ("Straight leg raises",              "straight_leg_raise"),
    ("Straight leg raise",               "straight_leg_raise"),
    ("Side leg raises",                  "side_leg_raise"),
    ("Side leg raise",                   "side_leg_raise"),
    ("Single leg stretch",               "single_leg_stretch"),
    ("Pelvic bridging",                  "pelvic_bridging"),
    ("Pelvic rotations",                 "pelvic_rotations"),
    ("Pelvic tilt",                      "pelvic_tilt"),
    ("Leg scissors",                     "leg_scissors"),
    ("Leg circles",                      "leg_circles"),
    ("Wall squats",                      "wall_squat"),
    ("Clamshells",                       "clamshells"),
    ("Lunges",                           "lunges"),
    ("Squats",                           "squats"),
]

def parse_exercises(text):
    """Split the Exercises cell into (key, reps, hold) plus the block set count."""
    m = re.search(r"\((\d)\s*sets?\s+all", text)
    sets = int(m.group(1)) if m else 1
    text = re.sub(r"\(\d\s*sets?\s+all[^)]*\)", "", text)

    # find where each known exercise name starts
    hits = []
    for name, key in EX:
        for m in re.finditer(re.escape(name), text):
            hits.append((m.start(), m.end(), key, name))
    hits.sort()
    # drop overlaps (e.g. 'Squats' inside 'Wall squats')
    kept = []
    for h in hits:
        if kept and h[0] < kept[-1][1]:
            continue
        kept.append(h)

    items = []
    for i, (s, e, key, name) in enumerate(kept):
        tail = text[e: kept[i + 1][0] if i + 1 < len(kept) else len(text)]
        if re.search(r"no\s+hold", tail, re.I):
            hold = None
        else:
            hm = re.search(r"x\s*(\d+)\s*sec\s*hold", tail, re.I)
            hold = int(hm.group(1)) if hm else None
        rm = re.search(r":\s*(\d+)", tail)
        reps = int(rm.group(1)) if rm else 1
        items.append({"key": key, "reps": reps, "hold": hold, "sets": sets})
    return items, sets

def parse_pfmt(text):
    """Split the PFMT cell into positioned slow-holds plus a quick-contraction item."""
    items = []
    for pos in ("Supine", "Sitting", "Standing"):
        m = re.search(
            pos + r"\s*:\s*[Ss]low-hold\s*(\d+)\s*sec\s*[+\u2013-]\s*relax\s*(\d+)\s*sec\s*\((\d+)\s*reps?\s*x\s*(\d+)\s*sets?\)",
            text, re.I)
        if m:
            items.append({"key": "pfmt_slow", "position": pos.lower(),
                          "hold": int(m.group(1)), "relax": int(m.group(2)),
                          "reps": int(m.group(3)), "sets": int(m.group(4))})
    q = re.search(r"Quick(?:\s+contractions)?\s*:\s*(\d+)\s*reps?\s*[x\u00d7]\s*(\d+)\s*sets?", text, re.I)
    if q:
        items.append({"key": "pfmt_quick", "position": None, "hold": None,
                      "relax": None, "reps": int(q.group(1)), "sets": int(q.group(2))})
    return items

lines = open(SRC, encoding="utf-8").read().split("\n")
protocols, cur = {}, None
for l in lines:
    if "Incontinence +" in l:
        cur = l.split("(")[0].strip()
        protocols[cur] = {"name": cur, "blocks": []}
    elif l.startswith("Week ") and "|" in l and cur:
        parts = [x.strip() for x in l.split("|")]
        wk = parts[0]
        wm = re.match(r"Week\s*(\d+)\W+(\d+)", wk)
        dm = re.search(r"(\d+)\s*days?/week", wk)
        ex_items, sets = parse_exercises(parts[2])
        protocols[cur]["blocks"].append({
            "startWeek": int(wm.group(1)), "endWeek": int(wm.group(2)),
            "daysPerWeek": int(dm.group(1)) if dm else None,
            "focus": parts[3] if len(parts) > 3 else "",
            "sets": sets,
            "items": parse_pfmt(parts[1]) + ex_items,
        })

# protocol-level default frequency, from the prose above each table
DEFAULT_DAYS = 5
for p in protocols.values():
    for b in p["blocks"]:
        if b["daysPerWeek"] is None:
            b["daysPerWeek"] = DEFAULT_DAYS

json.dump(protocols, open(sys.argv[1], "w", encoding="utf-8"), indent=1, ensure_ascii=False)

print(f"{'protocol':38s} days/week      items/day")
for name, p in protocols.items():
    d = "/".join(str(b["daysPerWeek"]) for b in p["blocks"])
    i = "/".join(str(len(b["items"])) for b in p["blocks"])
    print(f"{name:38s} {d:14s} {i}")
