#!/usr/bin/env python3
"""Record your progress in rtl_challenge_db.csv.

`make sim` drops a marker file in a question folder when that language passes
all tests:  PASS_SV, PASS_VHDL, or PASS_TLV.  This script sweeps every question
folder, looks for those markers, and writes SV / VHDL / TLV columns into the
CSV (the cell shows "PASS" where you've solved it, blank otherwise).

Usage (from the repo root):
    python3 update_csv.py
"""
import csv
import os

BASE = os.path.dirname(os.path.abspath(__file__))
CSV_PATH = os.path.join(BASE, "rtl_challenge_db.csv")
LANGS = ["SV", "VHDL", "TLV"]


def main():
    with open(CSV_PATH, newline="") as fh:
        rows = list(csv.reader(fh))
    if not rows:
        raise SystemExit("rtl_challenge_db.csv is empty")

    header = rows[0]
    # Keep the original metadata columns; drop any language columns from a
    # previous run so re-running stays idempotent.
    keep = [c for c in header if c not in LANGS]
    keep_idx = [header.index(c) for c in keep]

    out = [keep + LANGS]
    counts = {lang: 0 for lang in LANGS}

    for row in rows[1:]:
        if not row or not row[0].strip():
            continue
        qid = row[0].strip()
        meta = [row[i] if i < len(row) else "" for i in keep_idx]
        marks = []
        for lang in LANGS:
            solved = os.path.isfile(os.path.join(BASE, "questions", qid, f"PASS_{lang}"))
            marks.append("PASS" if solved else "")
            if solved:
                counts[lang] += 1
        out.append(meta + marks)

    with open(CSV_PATH, "w", newline="") as fh:
        csv.writer(fh).writerows(out)

    total = len(out) - 1
    print(f"Updated {os.path.basename(CSV_PATH)}")
    for lang in LANGS:
        print(f"  {lang:<4}: {counts[lang]}/{total} solved")


if __name__ == "__main__":
    main()
