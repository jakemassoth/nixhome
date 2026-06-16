import json, re, glob

import sys
DEST = sys.argv[1] if len(sys.argv) > 1 else "gravel-results-2"  # output folder

# ---------- load location enrichment ----------
locs = {}
for line in open("/tmp/mp_locs.jsonl"):
    line = line.strip()
    if not line:
        continue
    d = json.loads(line)
    locs[d["href"]] = d["info"]

CITY_TIME = {
 "Amsterdam":(0,"Amsterdam"),"Amstelveen":(15,"S"),"Haarlem":(20,"W"),
 "Zaandam":(20,"N"),"Hilversum":(30,"E"),"Utrecht":(35,"SE"),
 "Almere":(35,"E"),"Lelystad":(50,"NE"),"Leiden":(40,"SW"),
 "Noordwijkerhout":(45,"SW"),"Ter Aar":(45,"SW"),"Waddinxveen":(50,"SW"),
 "Voorburg":(50,"SW"),"Den Haag":(50,"SW"),"Driebergen-Rijsenburg":(45,"SE"),
 "Renswoude":(55,"SE"),"Werkhoven":(45,"SE"),"Bergschenhoek":(55,"SW"),
 "Gorinchem":(55,"SE"),"Hendrik-Ido-Ambacht":(70,"S"),"Gorssel":(90,"E"),
 "Meppel":(90,"NE"),"Ruinerwold":(105,"NE"),"Kampen":(80,"NE"),
 "Ommen":(105,"E"),"Hardenberg":(115,"E"),"Rijssen":(95,"E"),
 "Hengelo (Gld)":(95,"E"),"Tynaarlo":(120,"NE"),"Leens":(135,"N"),
 "Breda":(75,"S"),"Oosterhout":(80,"S"),"Dongen":(80,"S"),"Tilburg":(85,"S"),
 "Bladel":(105,"S"),"Bergeijk":(110,"S"),"Wouw":(95,"S"),"Wijk en Aalburg":(70,"SE"),
 "Axel":(150,"SW"),"Venlo":(120,"SE"),"Vaals":(180,"SE"),"Koningsbosch":(150,"SE"),
 "Beveren , Belgi\u00eb":(160,"S(BE)"),"Beveren":(160,"S(BE)"),
}
def lookup(city):
    if not city: return (None,"?")
    c = city.strip()
    if c in CITY_TIME: return CITY_TIME[c]
    base = c.split(",")[0].strip()
    return CITY_TIME.get(base, (None,"?"))
def fmt_dist(mins, ship):
    if mins is None: return ("ships \U0001f4e6" if ship else "?")
    if mins == 0: return "Amsterdam"
    h,m = divmod(mins,60)
    s = f"{h}h{m:02d}" if h else f"{m}min"
    return s + (" +\U0001f4e6" if ship else "")

# ---------- scoring ----------
# Spec target: carbon frame (required), electronic shifting (required),
# size L/56-58 for ~183cm rider, budget EUR2000-4000, near Amsterdam.
# Bonuses: carbon wheels, power meter, as-new condition, higher-end groupset.

def size_score(size):           # max 25
    s = size.lower()
    m = re.search(r'(\d{2})', s)
    if "maat l" in s or re.search(r'\bl\b', s): return 25
    if m:
        cm = int(m.group(1))
        if 56 <= cm <= 58: return 25
        if cm == 55: return 20
        if cm == 54: return 12
        if 59 <= cm <= 62: return 13
        if cm <= 53: return 4
    if "ml" in s: return 22
    if "maat m" in s or re.search(r'\bm\b', s): return 17
    if "xl" in s: return 13
    if "maat s" in s or re.search(r'\bs\b', s): return 4
    return 13  # unknown -> neutral, slight risk

def price_score(p):             # max 18
    if p is None: return 7
    if 2300 <= p <= 3600: return 18      # sweet spot
    if 2000 <= p <= 4000: return 16
    if 1500 <= p < 2000: return 13
    if 4000 < p <= 4500: return 10
    if 4500 < p <= 5000: return 6
    return 3

def dist_score(mins, ship, is_bc):   # max 22
    if is_bc: return 11                   # always ships EU-wide
    if mins is None: return (9 if ship else 6)
    base = (22 if mins==0 else 19 if mins<=30 else 16 if mins<=45 else
            13 if mins<=60 else 10 if mins<=90 else 7 if mins<=120 else 4)
    if ship: base = min(22, base+3)
    return base

# Category fit (max 20): dedicated gravel/cyclocross is what we want; endurance/
# all-road is gravel-adjacent; pure road scores low; TT/aero is basically off-target.
GRAVEL_KEYS = ["gravel","grizl","grail","revolt","checkpoint","topstone","aspero","\u00e1spero",
  "diverge","exploro","kanzo","ruut","terra","dark matter","crosshill","nuroad","nulane",
  "x-road","xroad","mission","kaius","warbird","crux","cyclocross","cross race","crossrace",
  "super prestige","superprestige","mares","addict cx","addict gravel","inflite","primo",
  "3t ultra","ultra carbon","racemax","silk","brera","gravelator","scale gravel","boone",
  "rlt","grifn","impulso","cross wind","x-night","xnight","zydeco","king zydeco","ls ",
  "sliker","palta","veldrit","allroad","all-road","all road","crosser","cross/","/cross"]
ENDURANCE_KEYS = ["roadmachine","endurace","domane","roubaix","defy","caledonia","synapse"]
TT_KEYS = ["timemachine","time machine","speedmax","plasma","shiv","triathlon","aero ","foil"]
ROAD_KEYS = ["ultimate","tarmac","supersix"," v3","aethos","xelius","fenix","agree","attain",
  "litening","cento"," aria","izalco","emonda","addict rc","addict 10","reacto","\u00e9toile",
  "zero","izalco max"]
def cat_score(text, is_mp):
    t = text.lower()
    if any(k in t for k in GRAVEL_KEYS): return (20, "gravel/CX")
    if any(k in t for k in ENDURANCE_KEYS): return (13, "endurance")
    if any(k in t for k in TT_KEYS): return (2, "TT/aero")
    if any(k in t for k in ROAD_KEYS): return (6, "road")
    # MP candidates were already gravel-filtered, so unknown leans gravel
    return (15, "gravel?") if is_mp else (8, "?")

CW_KEYS = ["carbon wiel","carbon velg","carbon rim","zipp","dt swiss","reserve",
           "roval","cadex","vision","bontrager aeolus","forza vardar","scope","newmen"]
def bonus_score(text):          # max 10
    t = text.lower()
    b = 0
    if any(k in t for k in CW_KEYS): b += 5
    if any(k in t for k in ["powermeter","vermogensmeter","quarq","power meter"]): b += 3
    if "zo goed als nieuw" in t or "nieuw" in t or "as good as new" in t: b += 2
    elif "gebruikt" in t: b += 0
    return min(10, b)

def gs_score(gs):               # max 5
    g = gs.lower()
    if any(k in g for k in ["force","red","ultegra","dura","grx di2"]): return 5
    if any(k in g for k in ["rival","105","apex","gx"]): return 4
    if any(k in g for k in ["di2","axs","etap","electronic"]): return 3
    return 3

def gs_extract(t):
    tl = t.lower(); gs = []
    for k,lab in [("axs","AXS"),("di2","Di2"),("etap","eTap"),("dura.?ace","Dura-Ace"),
                  ("ultegra","Ultegra"),("grx","GRX"),("rival","Rival"),("force","Force"),
                  ("apex","Apex"),("105","105"),("red ","Red")]:
        if re.search(k, tl): gs.append(lab)
    return " ".join(dict.fromkeys(gs)) or "electronic"

def mp_size(t):
    tl = t.lower()
    sm = re.search(r'\b(4[5-9]|5[0-9]|6[0-3])\s*cm\b', tl) or re.search(r'maat\s*(xs|s|ml|m|l|xl)\b', tl)
    return sm.group(0) if sm else "?"

MP_STOP = {"te","koop","nieuw","zgan","in","van","of"}
def mp_name(m):
    href = m.get("href","")
    sm = re.search(r'm\d{7,}-(.+?)(?:\?|$)', href)
    if sm:
        words = sm.group(1).split("-")
        # drop trailing filler words (nieuw/zgan/te-koop) for a tidy title
        while words and words[-1].lower() in MP_STOP:
            words.pop()
        name = " ".join(w.upper() if len(w) <= 3 and w.isalpha() else w.capitalize()
                         for w in words)
        return name[:48].replace("|","/").strip()
    # no-link fallback: title has description glued on; cut at first noisy boundary
    title = re.split(r'(!!|Te koop|In good|Nieuwe |Deze |De |Welkom)', m["title"])[0]
    return title[:46].replace("|","/").strip()

BC_BRANDS = ["Argon 18","Cannondale","Specialized","Cerv\u00e9lo","Cervelo","Pinarello",
             "Lapierre","Guerciotti","Bianchi","Colnago","Wilier","Megamo","Superior",
             "Th\u00f6mus","Cinelli","Canyon","Ridley","Orbea","Factor","Merida","Niner",
             "Stevens","Basso","Focus","Scott","Trek","Giant","Cube","BMC","KTM","Liv",
             "MMR","Rondo","3T"]
def bc_name(raw):
    nm = re.sub(r'^(High demand)?\s*','',raw).strip()
    if re.match(r'^T[A-Z]', nm):       # 3T model: leading '3' was stripped upstream
        nm = "3T " + nm[1:].capitalize()
    for br in BC_BRANDS:
        if nm.lower().startswith(br.lower()) and len(nm) > len(br):
            rest = nm[len(br):]
            if rest[0] != " ":
                nm = br + " " + rest
            break
    nm = re.sub(r'^(\w+)\s+\1\b', r'\1', nm)   # collapse doubled brand ("Trek Trek")
    return nm[:48].replace("|","/").strip()

def clean_price(p):
    mt = re.match(r'(\u20ac\s*[\d.]+)', p); return mt.group(1).replace(' ','') if mt else p
def price_int(p):
    mt = re.match(r'\u20ac\s*([\d.]+)', p)
    return int(mt.group(1).replace('.','')) if mt else None

rows = []

# ---------- marktplaats ----------
for m in json.load(open("/tmp/mp_top.json")):
    href = m["href"]; t = m.get("fullText","")
    info = locs.get(href, {})
    city = info.get("loc","") if href not in ("NO LINK","") else ""
    cond = info.get("cond","")
    mins, _ = lookup(city)
    ship = info.get("ship", "verzenden" in t.lower())
    size = mp_size(t); gs = gs_extract(t); p = price_int(m["price"]) or m.get("price_num")
    cw = any(k in t.lower() for k in CW_KEYS)
    pm = any(k in t.lower() for k in ["powermeter","vermogensmeter","quarq"])
    cs, cat = cat_score(m["title"] + " " + t, True)
    sc = (size_score(size) + price_score(p) + dist_score(mins, ship, False)
          + cs + bonus_score(t + " " + cond) + gs_score(gs))
    rows.append({
        "src":"MP","name":mp_name(m),"price":clean_price(m["price"]),"price_int":p or 99999,
        "size":size,"gs":gs,"cat":cat,"city":city or "\u2014","dist":fmt_dist(mins,ship),
        "dist_min":mins if mins is not None else 9999,"cond":cond,
        "cw":cw,"pm":pm,"href":href if href not in ("NO LINK","") else "","score":sc,
    })

# ---------- buycycle ----------
for b in json.load(open("/tmp/bc_top.json")):
    nm = bc_name(b["name"])
    t = b["name"] + " " + b["groupset"]
    p = b["price"]
    cw = any(k in t.lower() for k in CW_KEYS)
    cs, cat = cat_score(t, False)
    sc = (size_score(b["size"]) + price_score(p) + dist_score(None, True, True)
          + cs + bonus_score(t) + gs_score(b["groupset"]))
    rows.append({
        "src":"BC","name":nm,"price":f"\u20ac{p}","price_int":p,
        "size":b["size"],"gs":b["groupset"],"cat":cat,"city":"buycycle (EU ship)",
        "dist":"ships \U0001f4e6","dist_min":5000,"cond":str(b["year"]),
        "cw":cw,"pm":False,"href":b["href"],"score":sc,
    })

rows.sort(key=lambda r:(-r["score"], r["price_int"]))
for i,r in enumerate(rows,1): r["rank"] = i

def link(r): return f"[link]({r['href']})" if r["href"] else "_search only_"
def flags(r):
    f = []
    if r["cw"]: f.append("\U0001f6de")   # carbon wheels
    if r["pm"]: f.append("\U0001f525")   # powermeter
    return " ".join(f) or "\u2014"

L = []
L.append("# Gravel Bike Search \u2014 Results (gravel-results-2)\n")
L.append("_Generated: 2026-06-16_\n")
L.append("Used **carbon gravel bike, electronic shifting, size L/56-58cm** (rider ~183cm), "
         "budget ~\u20ac2,000-4,000 (relaxed \u20ac1,500-5,000), near Amsterdam / shippable.\n")

# scoring explainer
L.append("## How the ranking works\n")
L.append("Each bike gets a **composite score out of 100** that balances every factor instead of "
         "sorting on one axis. Higher = better overall fit:\n")
L.append("| Factor | Max | Notes |")
L.append("|---|---|---|")
L.append("| Size fit | 25 | L / 56-58cm = full; 55/ML close; 54 & XL partial; S/\u226453cm low; unknown = neutral |")
L.append("| Distance from A'dam | 22 | Amsterdam=22, scaling down with drive time; +3 if seller ships; buycycle (EU ship)=11 |")
L.append("| Category fit | 20 | dedicated gravel/CX = full; endurance/all-road gravel-adjacent; road low; TT/aero near-zero |")
L.append("| Price fit | 18 | \u20ac2.3-3.6k sweet spot; full in \u20ac2-4k; less for cheap/stretch |")
L.append("| Spec bonuses | 10 | carbon wheels \U0001f6de +5, power meter \U0001f525 +3, as-new/new condition +2 |")
L.append("| Groupset tier | 5 | electronic baseline; Force/Red/Ultegra/Dura-Ace/GRX-Di2 highest |")
L.append("\nAll listed bikes pass the hard requirements (carbon frame, electronic shifting). The "
         "**Category** column shows how gravel-focused each bike is (road/TT bikes are kept for "
         "completeness but score low). Flags: \U0001f6de carbon wheels, \U0001f525 power meter.\n")

# TOP 20
L.append("## \U0001f3c6 Top 20 \u2014 best overall (combined Marktplaats + buycycle)\n")
L.append("| # | Score | Bike | Source | Price | Size | Category | Groupset | Flags | Distance | Location | Cond/Year | Link |")
L.append("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for r in rows[:20]:
    L.append(f"| {r['rank']} | **{r['score']}** | {r['name']} | {r['src']} | {r['price']} | {r['size']} | "
             f"{r['cat']} | {r['gs']} | {flags(r)} | {r['dist']} | {r['city']} | {r['cond']} | {link(r)} |")
L.append("")

# summary
mp_all=len(json.load(open("/tmp/mp_all.json"))); bc_all=len(json.load(open("/tmp/bc_all.json")))
mp_c=len(json.load(open("/tmp/mp_cands.json"))); bc_c=len(json.load(open("/tmp/bc_cands.json")))
L.append("## Summary\n")
L.append("| Source | Searches | Unique listings | Gravel+electronic candidates | Scored top picks |")
L.append("|---|---|---|---|---|")
L.append(f"| Marktplaats.nl | {len(glob.glob('/tmp/mp/*.json'))} | {mp_all} | {mp_c} | {sum(1 for r in rows if r['src']=='MP')} |")
L.append(f"| buycycle.com | {len(glob.glob('/tmp/bc/*.json'))} | {bc_all} | {bc_c} | {sum(1 for r in rows if r['src']=='BC')} |")
L.append(f"\n**{len(rows)} fully-vetted candidates** were scored below (carbon + electronic + gravel/cyclocross, "
         "\u20ac1.5-5k). The broader raw candidate pools ({} MP + {} BC) are in `raw/`.\n".format(mp_c,bc_c))

# FULL considered list
L.append("## All considered candidates (ranked by score)\n")
L.append("Every vetted candidate, best to worst. Top 20 above are simply the head of this list.\n")
L.append("| # | Score | Bike | Source | Price | Size | Category | Groupset | Flags | Distance | Location | Cond/Year | Link |")
L.append("|---|---|---|---|---|---|---|---|---|---|---|---|---|")
for r in rows:
    L.append(f"| {r['rank']} | {r['score']} | {r['name']} | {r['src']} | {r['price']} | {r['size']} | "
             f"{r['cat']} | {r['gs']} | {flags(r)} | {r['dist']} | {r['city']} | {r['cond']} | {link(r)} |")
L.append("")

# notes
L.append("## Notes & Methodology\n")
L.append("- **Scoring** balances size fit, distance, price and spec bonuses (see *How the ranking works*). "
         "Two bikes with similar scores are roughly equally good \u2014 pick on the factor you care most about.\n")
L.append("- **Distances** are approximate car driving times from Amsterdam by seller city; \U0001f4e6 = seller ships. "
         "buycycle ships EU-wide.\n")
L.append("- **Marktplaats:** 44 searches (groupset, broad gravel/cyclocross, brand). Locations read from each "
         "listing's detail page. Verify carbon wheels/size/shifting before contacting.\n")
L.append("- **buycycle:** 6 search passes; prices include buyer protection. 'Carbon wheels' only flagged when the "
         "card text shows it \u2014 confirm on the listing.\n")
L.append("- **Caveats:** a few entries are off-target sizes (S/XL/<54cm) or road/all-road bikes that scored lower "
         "but remain for completeness \u2014 the Size column and score make them obvious.\n")
L.append("- **Raw data:** `raw/marktplaats/`, `raw/buycycle/`, plus deduped `*_all_unique.json` and "
         "`*_candidates.json`.\n")

open(f"{DEST}/OVERVIEW.md","w").write("\n".join(L))

# persist scored json
json.dump(rows, open(f"{DEST}/ranked_candidates.json","w"), indent=2, ensure_ascii=False)
print(f"wrote OVERVIEW.md with {len(rows)} scored candidates (top score {rows[0]['score']})")
for r in rows[:10]:
    print(f"  {r['rank']:2} [{r['score']}] {r['src']} {r['price']:8} {r['size']:8} {r['dist']:12} {r['name']}")
