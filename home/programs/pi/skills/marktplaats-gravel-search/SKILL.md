---
name: marktplaats-gravel-search
description: Search Marktplaats.nl for used gravel bikes with specific criteria (electronic shifting, carbon frame/wheels, size, budget, near Amsterdam). Dutch sellers categorize poorly — requires multiple broad searches and manual filtering. Use /browser-tools for DOM extraction. Use when searching for gravel bikes on Marktplaats.
---

# Marktplaats Gravel Bike Search

Searches Marktplaats.nl for used gravel bikes. Marktplaats is server-rendered HTML (not JS-heavy), so DOM extraction is fast. However, **Dutch sellers are bad at categorizing** — bikes end up in "Racefietsen", "Sportfietsen", "Mountainbikes", or "Fietsonderdelen". Run multiple broad searches and filter manually.

In all bash snippets, `{browser-tools}` means the base directory of the browser-tools skill (where `browser-nav.js`, `browser-eval.js`, etc. live).

## Search Queries (Run All — Categorization is Unreliable)

| # | URL | Purpose | Expected |
|---|-----|---------|----------|
| 1 | `https://www.marktplaats.nl/q/gravel+bike/` | Broad catch-all | ~400+ |
| 2 | `https://www.marktplaats.nl/q/gravelbike/` | One-word Dutch style | ~300+ |
| 3 | `https://www.marktplaats.nl/q/gravel+bike+sram+axs/` | SRAM electronic only | ~30 |
| 4 | `https://www.marktplaats.nl/q/gravel+bike+di2/` | Shimano electronic only | ~25 |
| 5 | `https://www.marktplaats.nl/q/carbon+gravel+di2/` | Carbon + Di2 combo | ~15 |
| 6 | `https://www.marktplaats.nl/q/carbon+gravel+axs/` | Carbon + AXS combo | ~15 |
| 7 | `https://www.marktplaats.nl/q/titanium+gravel+bike/` | Titanium alternative | ~10 |

**Always run the `sram+axs` and `di2` searches** — they catch electronic shifting bikes poorly titled in general results.

Search URLs support `+` for spaces. Price filters (`#f:2000,4000`) can be appended but are unreliable — sellers list prices in descriptions differently from the price field. Always manual-filter.

## Workflow

```bash
# Run each search
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/gravel+bike+sram+axs/'
sleep 3

# Extract listings
{browser-tools}/browser-eval.js '(function() {
  var listings = document.querySelectorAll("li, article, [class*=listing], [class*=search-result]");
  var results = [];
  for (var l of listings) {
    var text = l.textContent.trim();
    if (text.length > 50 && text.includes("€")) {
      results.push(text.slice(0, 400));
    }
  }
  return JSON.stringify(results.slice(0, 30), null, 2);
})()'
```

## Extracting Structured Listings (with Links)

**Always extract links.** Each listing has an `<a>` tag with an `href` to the detail page. Extract them together with the listing text:

```javascript
(function() {
  var listings = document.querySelectorAll("li, article, [class*=listing], [class*=search-result]");
  var results = [];
  for (var l of listings) {
    var text = l.textContent.trim();
    if (text.length > 50 && (text.includes("€") || text.includes("bieden"))) {
      var priceMatch = text.match(/€\s*[\d.,]+/);
      var locMatch = text.match(/(\d{1,2}\s\w{3}\s\d{2}\n)([A-Z][a-z]+)/);
      // Extract the listing URL — Marktplaats links contain "/v/"
      var links = l.querySelectorAll("a[href*='/v/']");
      var href = links.length > 0 ? links[0].href : "";
      // Fallback: some listings use block-level <a> tags
      if (!href) {
        var blockLinks = l.querySelectorAll("a[class*=coverLink], a[role=link]");
        href = blockLinks.length > 0 ? (blockLinks[0].href || "") : "";
      }
      results.push({
        title: text.split("\n")[0].slice(0, 100),
        price: priceMatch ? priceMatch[0] : "bieden",
        location: locMatch ? locMatch[2] : "unknown",
        href: href || "NO LINK — listing may be sold/removed or JS-only",
        fullText: text.slice(0, 350)
      });
    }
  }
  return JSON.stringify(results.slice(0, 25), null, 2);
})()
```

**Important:** Some Marktplaats listings use JavaScript navigation with `<a role="link">` tags that have no `href` attribute. These listings cannot be linked directly — note them as "NO LINK" and provide the search query that finds them instead.

## Navigating to a Listing

Click a listing link from search results:
```javascript
(function() {
  var links = document.querySelectorAll("a[href]");
  for (var a of links) {
    if (a.textContent.includes("SEARCH_TEXT")) {
      a.click();
      return "Clicked: " + a.textContent.slice(0, 100);
    }
  }
  return "Not found";
})()
```

Then extract details:
```javascript
document.body.innerText.slice(0, 5000)
```

## Listing Details

Key sections in Marktplaats ads:
- **Kenmerken (Characteristics):** Conditie, Merk, Materiaal, Framehoogte, Rem, Aantal versnellingen
- **Beschrijving (Description):** Free-text — **this is where real specs live**. Dutch sellers list groupsets, wheels, upgrades here, not in structured fields.
- **Location:** City name near seller info
- **Price:** Bolded price + "bieden" (offers accepted)
- **Seller:** "X jaar op Marktplaats", star rating, review count

## Dutch→English Glossary

| Dutch | English | Relevance |
|-------|---------|-----------|
| `carbon frame` / `volledig carbon` | Carbon frame / full carbon | ✅ Required |
| `carbon wielen` / `carbon velgen` | Carbon wheels / rims | ✅ Target |
| `elektronisch schakelen` | Electronic shifting | ✅ Required |
| `SRAM AXS` / `Shimano Di2` / `GRX Di2` | Electronic groupsets | ✅ Target |
| `powermeter` / `vermogensmeter` | Power meter | 🔥 Bonus |
| `maat L` / `56` / `58` / `56cm` / `58cm` | Size L / 56cm / 58cm | ✅ Target |
| `zo goed als nieuw` | As good as new | 👍 Condition |
| `gebruikt` | Used | ⚠️ Check condition |
| `nieuw` | New | 👍 |
| `ophalen` | Pick up only | 📍 Must be nearby |
| `verzenden` | Shipping available | 📦 Can ship |
| `bieden` | Offers accepted | 💰 Negotiate |
| `incl. factuur/garantie` | Includes invoice/warranty | 👍 |
| `aluminium wielen` / `alu wielen` | Aluminum wheels | ⚠️ Not carbon |
| `alu frame` | Aluminum frame | ❌ Skip |
| `mechanisch` | Mechanical shifting | ❌ Skip |
| `frameset` / `alleen frame` | Frame only | ❌ Skip |
| `e-bike` / `elektrische fiets` | Electric bike | ❌ Different category |

## Red Flags
- `maat S` / `52cm` / `54cm` — too small for 183cm
- `maat XL` / `61cm` — too large
- `mechanisch` — mechanical shifting (not electronic)
- `alu frame` — aluminum frame (skip unless budget)
- `frameset` / `alleen frame` — incomplete bike
- `e-bike` / `e-gravel` — electric

## Location Proximity to Amsterdam

| City | Approx. time | Direction |
|------|-------------|-----------|
| Amsterdam | 0min | — |
| Amstelveen | 15min | South |
| Haarlem | 20min | West |
| Zaandam | 20min | North |
| Hilversum | 30min | East |
| Utrecht | 35min | Southeast |
| Almere | 35min | East |
| Leiden | 40min | Southwest |
| Den Haag / Voorburg | 45min | Southwest |
| Rotterdam | 1h | South |
| Gorssel / Deventer | 1.5h | East |
| Tilburg / Eindhoven | 1.5h | South |
| Groningen | 2h | North |

## Evaluating a Bike

Check criteria in priority order:

1. **Frame:** Carbon (or titanium as premium alternative). Check Materiaal and Beschrijving.
2. **Shifting:** Electronic. Look for "AXS", "Di2", "elektronisch schakelen" anywhere in text.
3. **Size:** L/56-58cm. Check Framehoogte and Beschrijving. Must fit 183cm.
4. **Wheels:** Carbon. Look for "carbon wielen/velgen" or known brand models (DT Swiss, Zipp, Vision, Forza, Bontrager carbon lines). Aluminum wheels are common — "alu wielen" = skip unless budget allows upgrade.
5. **Price:** €2,000-4,000. "Bieden" means negotiable.
6. **Power meter:** Bonus. "powermeter" or "vermogensmeter" in text.
7. **Location:** Close to Amsterdam
8. **Condition:** "Zo goed als nieuw" or "Nieuw" preferred. "Gebruikt" needs scrutiny.

## Deep-Dive Search Strategy

**Dutch sellers are terrible at categorizing and titling.** A gravel bike with Di2 might be listed as "racefiets" with no mention of "gravel" in the title. You must cast a very wide net. Aim to collect **50-100 candidate listings** before narrowing.

### Pass 1: Electronic Groupset Searches (Highest Signal)

Search by groupset name directly — these catch bikes regardless of category:

```bash
# SRAM AXS (all variants)
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/sram+force+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/sram+rival+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/sram+red+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/sram+apex+axs/'

# Shimano Di2 (all variants)
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/grx+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/ultegra+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/dura+ace+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/105+di2/'

# Dutch variants
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/elektronisch+schakelen/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/di2+fiets/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/axs+fiets/'
```

**This is the most important pass.** Many sellers put the groupset in the title but not the bike type.

### Pass 2: Carbon Gravel Broad Searches

```bash
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/gravel+bike/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/gravelbike/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/carbon+gravel/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/carbon+gravelbike/'
```

### Pass 3: Cyclocross & All-Road Terms

```bash
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/cyclocross+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/cyclocross+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/cyclocrossfiets/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/veldritfiets/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/allroad+fiets/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/gravelracer/'
```

### Pass 4: Brand + Electronic (No "Gravel" Required)

Search premium brands with electronic groupsets. These catch road/endurance/all-road bikes that may be gravel-capable:

```bash
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/canyon+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/canyon+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/specialized+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/specialized+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/cervelo+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/cervelo+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/trek+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/trek+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/giant+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/giant+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/scott+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/bmc+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/ridley+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/orbea+di2/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/factor+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/3t+axs/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/cannondale+di2/'
```

### Pass 5: Check Multiple Categories

Marktplaats has sub-categories. Sellers often pick the wrong one. Search within each relevant category:

- `Fietsen | Racefietsen` — most gravel bikes end up here
- `Fietsen | Heren | Sportfietsen en Toerfietsen` — touring/endurance bikes
- `Fietsen | Mountainbikes en ATB` — some sellers think gravel = MTB
- `Fietsonderdelen` — occasionally complete bikes listed as parts

### Pass 6: Pagination — Extract ALL Results

Marktplaats shows ~30 listings per page with pagination. **Do not stop at page 1.** Navigate through every page of results for each high-signal search. Look for "Volgende" (Next) links or numbered page buttons.

```javascript
// Find and click "Next" page
(function() {
  var links = document.querySelectorAll("a");
  for (var a of links) {
    if (a.textContent.includes("Volgende")) {
      a.click();
      return "Clicked next page";
    }
  }
  return "No next page";
})()
```

After each page, extract listings and continue. Merge all results before filtering.

### Pass 7: Amsterdam-First Scan

Filter results for Amsterdam proximity by checking location strings. After extracting all listings, prioritize:
- Amsterdam, Amstelveen, Haarlem, Zaandam, Hilversum, Utrecht, Almere
- Listings with "Verzenden" (shipping) for further locations

### Pass 8: Carbon Wheel Keyword Search

Some sellers list wheels in the title:

```bash
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/carbon+wielen+gravel/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/zipp+gravel/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/dt+swiss+gravel/'
{browser-tools}/browser-nav.js 'https://www.marktplaats.nl/q/carbon+velgen+gravel/'
```

### Budget Flexibility

**Relax the budget to €1,500-5,000** when collecting candidates. Include:
- Bikes under €2,000 — may be undervalued or have room for wheel upgrades
- Bikes €4,000-5,000 — "stretch" candidates, may accept offers
- "Bieden" (offers) listings — the listed price may be negotiable
- Flag budget status in the final report

### Time Commitment

A thorough Marktplaats deep dive means **20-30 searches**, paginating through all results for high-signal queries. Expect to extract **100-200 raw listings**, manually review ~50, and surface 15-25 candidates.

### Deduplication

The same bike often appears in multiple search results (e.g., both "gravel bike di2" and "ridley di2"). Deduplicate by Marktplaats ad number (the `mXXXXXXXX` in the URL) before compiling the final report.

## Results Format

Present findings as a markdown table with: Bike name/year/model, Price (note "bieden"), Size, Frame material, Groupset, Wheels (carbon? model), Power meter (yes/no), Location (city, distance from Amsterdam), Seller rating/years, Key notes from description, Link (if available).

### Location & Distance from Amsterdam (Required)

**The seller city is not reliable in search results** — extract it from each candidate's detail page. The location element is `[class*=Location]` / `[class*=location]` / `#vip-seller-location`:

```javascript
(function(){
  var el=document.querySelector("[class*=Location], [class*=location], #vip-seller-location, [data-testid*=location]");
  var bt=document.body.innerText;
  var cm=bt.match(/Conditie\s*\n([^\n]+)/);
  return JSON.stringify({
    loc: el ? el.textContent.trim() : "",
    cond: cm ? cm[1].trim() : "",
    ship: /Verzenden/i.test(bt)
  });
})()
```

Batch-visit every linked top candidate, record `loc` + `cond` + `ship`, then map the city to an approximate **car driving time from Amsterdam** (see the *Location Proximity to Amsterdam* table). Mark sellers offering shipping with 📦 — distance matters less for them. Always include a **Distance from A'dam** column in the final table.

### Building the Combined Overview

After collecting candidates, hand the enriched candidate JSON to the **`/make-overview`** skill to produce a `OVERVIEW.md` with a ranked shortlist across all sources. Save raw per-search JSON, deduped `*_all_unique.json`, and `*_candidates.json` alongside it. See `/make-overview` for the exact format and ranking rules.
