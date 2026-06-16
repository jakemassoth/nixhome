---
name: make-overview
description: Compile gravel-bike search results from multiple sources (Marktplaats, buycycle) into a single OVERVIEW.md that scores every candidate on a composite 0-100 model (size, distance, category, price, spec, groupset), surfaces a combined Top 20, and lists all considered candidates ranked. Use after running /marktplaats-gravel-search and/or /buycycle-gravel-search to dump results and an overview into an output folder.
---

# Make Overview

Takes candidate listings collected by the gravel-search skills (`/marktplaats-gravel-search`,
`/buycycle-gravel-search`) and produces a single `OVERVIEW.md` plus a tidy raw-data tree in an
output folder. The headline is a **ranked shortlist that merges all sources**, followed by
per-source detail tables.

## When to Use

After a search session, when the user asks to "dump the results" and/or "make an overview".
Typical invocation: collect candidates → call this skill with the output folder.

## Output Folder Layout

```
<output-folder>/
  OVERVIEW.md                          ← scoring explainer + Top 20 + all considered (the deliverable)
  ranked_candidates.json               ← full scored & ranked list (both sources combined)
  marktplaats_top_candidates.json      ← enriched top picks (incl. location, distance, condition)
  buycycle_top_candidates.json
  raw/
    marktplaats/*.json                 ← one file per search query
    buycycle/*.json
    marktplaats_all_unique.json        ← deduped union of all searches
    marktplaats_candidates.json        ← filtered (gravel + electronic)
    buycycle_all_unique.json
    buycycle_candidates.json
```

**Always create the folder with `mkdir -p` first**, write into it explicitly with absolute
paths, and verify with `ls` afterward — output files have a habit of landing at the repo root
if the destination path is wrong. If the user names a folder (e.g. `gravel-results-2`), use
exactly that.

## OVERVIEW.md Structure

The file must contain these sections, in order:

1. **Title + metadata** — generation date and the search brief (frame, shifting, size, budget,
   location).
2. **How the ranking works** — a short table explaining the composite score and its factor
   weights (see *Scoring Model* below). This makes the ranking transparent.
3. **🏆 Top 20 — best overall (combined Marktplaats + buycycle)** — the head of the ranked list,
   merging both sources. This is the headline deliverable. Columns:
   `# | Score | Bike | Source | Price | Size | Category | Groupset | Flags | Distance | Location | Cond/Year | Link`
4. **Summary** — a small table: source, # searches, # unique listings, # candidates, # scored picks.
5. **All considered candidates (ranked by score)** — **every** vetted candidate, best to worst,
   same columns as the Top 20. The Top 20 is simply the head of this list. Never drop candidates —
   the user wants to see everything that was considered.
6. **Notes & Methodology** — searches run, how locations were obtained, how scoring balances the
   factors, caveats (off-target sizes/road bikes that scored low but remain, scraping quirks),
   and a pointer to the raw data.

### Scoring Model (balance every factor — do not sort on one axis)

Give each bike a **composite score out of 100** so a bike that is slightly off on one axis (e.g.
a bit far away) is not buried below a worse bike that happens to win that single axis. All listed
bikes must already pass the hard requirements (carbon frame, electronic shifting); the score then
ranks *fit*:

| Factor | Max | How |
|--------|-----|-----|
| Size fit | 25 | L / 56-58cm = full; 55/ML close; 54 & XL partial; S/≤53cm low; unknown = neutral |
| Distance from Amsterdam | 22 | Amsterdam = 22, scaling down with drive time; +3 if seller ships; buycycle (EU ship) = 11 |
| Category fit | 20 | dedicated gravel/cyclocross = full; endurance/all-road gravel-adjacent (~13); pure road low (~6); TT/aero near-zero (~2) |
| Price fit | 18 | €2.3–3.6k sweet spot (18); full in €2–4k (16); less for cheap/stretch |
| Spec bonuses | 10 | carbon wheels 🛞 +5, power meter 🔥 +3, as-new/new condition +2 |
| Groupset tier | 5 | electronic baseline (3); Rival/105/Apex (4); Force/Red/Ultegra/Dura-Ace/GRX-Di2 (5) |

**Category fit matters a lot:** buycycle's road/endurance passes and broad Marktplaats searches
drag in road and even TT/aero bikes that meet carbon+electronic+size but are *not* gravel. Detect
bike category from the model name (keyword lists for gravel/CX, endurance, road, TT) and score it
so genuine gravel bikes rise to the top. Keep the road/TT bikes in the list (flagged via the
Category column) rather than deleting them.

Sort by **score descending**, then price ascending as a tiebreaker. Add a 1-based `rank`.

### Distance from Amsterdam

Marktplaats sellers list a city; map it to an approximate car driving time. buycycle ships
EU-wide, so use `📦 EU delivery` instead of a distance. Mark Marktplaats sellers that ship with
`+📦`. Use a lookup like:

| City | ~min | City | ~min |
|------|------|------|------|
| Amsterdam | 0 | Utrecht | 35 |
| Amstelveen | 15 | Almere | 35 |
| Haarlem | 20 | Leiden | 40 |
| Zaandam | 20 | Den Haag/Voorburg | 50 |
| Hilversum | 30 | Rotterdam | 60 |
| Breda/Oosterhout | 75–80 | Tilburg | 85 |
| Venlo | 120 | Groningen/Leens | 130+ |

Format minutes as `45min` or `1h15`, appending ` +📦` when the seller ships.

## Generator Script

Build the overview programmatically from the candidate JSON files. The script below is the
reference shape — adapt field names to whatever the search skills saved.

```python
import json, re

DEST = "<output-folder>"
mp = json.load(open("/tmp/mp_top.json"))   # marktplaats top candidates
bc = json.load(open("/tmp/bc_top.json"))   # buycycle top candidates
locs = {}                                   # href -> {loc, cond, ship} from detail pages
for line in open("/tmp/mp_locs.jsonl"):
    if line.strip():
        d = json.loads(line); locs[d["href"]] = d["info"]

CITY_TIME = {"Amsterdam":(0,""), "Utrecht":(35,"SE"), "Breda":(75,"S"), ...}
def lookup(city):
    if not city: return (None, "?")
    return CITY_TIME.get(city.split(",")[0].strip(), (None, "?"))
def fmt_dist(mins, ship):
    if mins is None: return ("?+📦" if ship else "?")
    if mins == 0: return "Amsterdam"
    h, m = divmod(mins, 60)
    return (f"{h}h{m:02d}" if h else f"{m}min") + (" +📦" if ship else "")

def price_int(p):
    m = re.match(r'€\s*([\d.]+)', p); return int(m.group(1).replace('.','')) if m else 99999

# Composite scoring — balance every factor (see Scoring Model table).
def size_score(size): ...      # max 25
def dist_score(mins, ship, is_bc): ...  # max 22 (buycycle EU-ship = 11)
def cat_score(text, is_mp): ...  # max 20, returns (points, label) via gravel/road/TT keyword sets
def price_score(p): ...        # max 18
def bonus_score(text): ...     # max 10 (carbon wheels / power meter / condition)
def gs_score(gs): ...          # max 5

rows = []  # one dict per bike from both sources
# For each candidate compute:
#   score = size + dist + category + price + bonus + groupset
# storing name, src, price, size, cat, gs, flags, distance, location, cond, href, score.

rows.sort(key=lambda r: (-r["score"], r["price_int"]))
for i, r in enumerate(rows, 1): r["rank"] = i

# Emit Markdown in order: scoring explainer → Top 20 (rows[:20]) → summary →
# ALL considered candidates (rows) → notes. Persist rows to ranked_candidates.json.
```

A full, working reference implementation of this generator lives at
`make_overview.py` in this skill directory — adapt its field names to whatever the
search skills saved, then run it to (re)generate `OVERVIEW.md`.

## Quality Checks Before Finishing

- Every bike has a **composite score**, and the list is sorted by score (not a single axis).
- The **Top 20** section is the head of the full ranked list, and **all** considered candidates
  appear below it — nothing is dropped.
- The score balances size, distance, category, price, spec bonuses and groupset, and the **How
  the ranking works** table is present so the weighting is transparent.
- Genuine gravel/CX bikes outrank road/TT bikes of similar spec; road/TT bikes remain in the
  list with a low Category score rather than being deleted.
- Every Marktplaats row has a real location + distance (not `?`) — if missing, re-visit the
  detail page.
- Bike names are clean (derive Marktplaats names from the URL slug; un-glue buycycle brands and
  restore 3T's stripped leading digit).
- Raw data is saved under `raw/`, the enriched `*_top_candidates.json` includes `location`,
  `distance_amsterdam`, and `condition` for Marktplaats, and `ranked_candidates.json` holds the
  full scored list.
- `ls <output-folder>` confirms files landed in the right place (not the repo root).
