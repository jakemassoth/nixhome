---
name: buycycle-gravel-search
description: Search buycycle.com for used gravel bikes with specific criteria (electronic shifting, carbon frame/wheels, size, budget, location). Buycycle uses JS-rendered React pages — requires /browser-tools for DOM inspection and interaction. Use when searching for gravel bikes on buycycle.
---

# Buycycle Gravel Bike Search

Searches buycycle.com for used gravel bikes. The site is JavaScript-rendered (React), so browser automation via the `/browser-tools` skill is required. Never use `curl` or non-browser HTTP — all content loads dynamically.

In all bash snippets, `{browser-tools}` means the base directory of the browser-tools skill (where `browser-nav.js`, `browser-eval.js`, etc. live).

## ⚠️ Cloudflare Bot Protection (Read First)

buycycle.com sits behind **Cloudflare bot protection**. Automated navigation frequently hits a challenge page instead of the real site:

- Symptoms: `browser-nav.js` returns `net::ERR_ABORTED`, the page title/body shows **"Just a moment..."**, or content never renders (very short `document.body.innerText`).
- A `curl` of the URL returns **HTTP 403** with a Cloudflare challenge body — this is expected and confirms the block. (Don't use curl for scraping, but it's a quick way to verify the block.)

**The fix — solve the challenge in the real browser window.** `browser-start.js` launches an *actual, visible Chrome window* (not headless), so a human can complete the Cloudflare check/CAPTCHA interactively:

```bash
# Launch the real Chrome window with a persistent profile
{browser-tools}/browser-start.js --profile

# Navigate to buycycle — this may show the Cloudflare "Just a moment" page
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl'
```

Then:
1. **Ask the user to switch to the Chrome window and solve the Cloudflare challenge** (checkbox / CAPTCHA). Wait for them to confirm.
2. Verify the real site loaded before continuing:
   ```bash
   {browser-tools}/browser-eval.js '({url: location.href, title: document.title, len: document.body.innerText.length})'
   ```
   A real page has a substantial `len` (thousands of chars) and a normal title — not "Just a moment...".
3. Because `--profile` persists cookies, the Cloudflare clearance usually lasts for the rest of the session, so subsequent `browser-nav.js` calls work normally. If the challenge reappears later, pause and ask the user to solve it again.

**Do not give up and report "site blocked" without first launching the window and asking the user to solve the challenge** — the visible browser exists precisely so a human can clear Cloudflare.

## Quick Start

```bash
# 1. Start Chrome (if not already running)
{browser-tools}/browser-start.js --profile

# 2. Navigate to gravel bikes
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/gravel'

# 3. Wait for React to render
sleep 3

# 4. Extract listings
{browser-tools}/browser-eval.js 'document.body.innerText.slice(0, 8000)'
```

## URL Structure

buycycle uses path-based filters. The base URL for gravel bikes is:

```
https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/gravel
```

Append path segments to filter:

| Filter | Path segment |
|--------|-------------|
| Size L (56-58cm) | `/frame-sizes/l` |
| Electronic shifting | `/shifts/electronic` |
| Size M (53-55cm) | `/frame-sizes/m` |

Example — gravel bikes, size L, electronic shifting:
```
https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/gravel/frame-sizes/l/shifts/electronic
```

**Important:** The homepage shows a cookie consent dialog on first visit. Dismiss it:

```javascript
(function() {
  var btn = Array.from(document.querySelectorAll("button"))
    .find(b => b.textContent.includes("Alles toestaan") || b.textContent.includes("Accept all"));
  if (btn) btn.click();
})()
```

## Filtering via UI

The filter bar shows: `Sort By | Size | Price | Brands | Frame material | Brake type | Year | More filters`

Click a filter button to open a `<section role="dialog">`, select options, then click **Apply**. Each dialog must be applied separately.

### Size Dialog
Options: `XXXS (<45)`, `XXS (45-47)`, `XS (48-49)`, `S (50-52)`, `M (53-55)`, **`L (56-58)`**, `XL (59-62)`, `XXL (>63)`
Target: `L (56-58)` for a 183cm rider.

### Shifting Dialog
Options: `Mechanical`, **`Electronic`**, `Other`, `None`
Target: `Electronic`

### Price Dialog
Two `<input type="number">` fields: placeholder `From` and `To`. Set values, dispatch events, click Apply.
**Note:** Price filtering via UI is unreliable — prefer manual filtering of results.

### Clicking Filter Buttons
```javascript
(function() {
  var btn = Array.from(document.querySelectorAll("button"))
    .find(b => b.textContent.trim() === "Size" && b.offsetParent !== null);
  if (btn) btn.click();
})()
```

## Extracting Listings

Product cards are React components. Extract by text pattern:

```javascript
(function() {
  var cards = document.querySelectorAll("[class*=product], [class*=card], [class*=item]");
  var bikes = [];
  for (var c of cards) {
    var text = c.textContent;
    if (text.includes("€") && (text.includes("SRAM") || text.includes("Shimano"))) {
      var link = c.querySelector("a[href]");
      bikes.push({
        text: text.slice(0, 300).replace(/\s+/g, " ").trim(),
        href: link ? link.href : ""
      });
    }
  }
  return JSON.stringify(bikes.slice(0, 30), null, 2);
})()
```

Each card shows: brand, model, size, year, groupset, price, MSRP.

The page also embeds the current API request JSON — useful for seeing active filters:
```javascript
(function() {
  var match = document.body.innerText.match(/"request":\{[^}]+\}/);
  return match ? match[0] : "not found";
})()
```

## Inspecting Individual Listings

```bash
{browser-tools}/browser-nav.js https://buycycle.com/en-nl/product/SLUG-ID
sleep 2
{browser-tools}/browser-eval.js 'document.body.innerText.slice(0, 5000)'
```

Key sections in listing text:
- **General Information:** Condition, Year, Shifting type, Brake type, Frame material
- **Size & fit:** Frame size, Recommended height (must include 183cm)
- **Bike details:** Fork, **Wheels** (check for carbon), Crank (powermeter?), Rear derailleur, Brakes
- **Seller info:** Location, last active, rating

## Evaluating a Bike

Check against these criteria in priority order:

1. **Frame material:** Must be Carbon
2. **Shifting:** Must be Electronic (SRAM eTap AXS, Shimano Di2). AXS/Di2 in name = electronic.
3. **Size:** L/56-58cm. Check "Recommended height" — should include 183cm.
4. **Wheels:** Look for carbon wheels. Known models:
   - ✅ Carbon: DT Swiss ERC 45/ERC 1100/GRC 1400, Zipp 303S/303 Firecrest/353 NSW, Vision SC40/Metron/Trimax Carbon, Forza Vardar DB, Bontrager Aeolus/RSL, Cadex
   - ❌ Aluminum: Fulcrum Rapid Red, DT Swiss G1800, stock/no-name wheels
5. **Price:** €2,000-4,000. Buycycle shows price + Buyer Protection fee (~€30-45).
6. **Power meter:** Bonus. Look for "Powermeter" or "Power" in crank text.
7. **Location:** Netherlands/Germany/Belgium preferred. EU-wide delivery available.
8. **Seller activity:** Prefer sellers active within last 3 days.

## Common Pitfalls

- **Cookie consent:** Must dismiss before navigation works.
- **Filter dialogs:** Must click "Apply" on each. They stay open as `<section role="dialog">`.
- **URL path order:** Frame sizes before shifts: `/frame-sizes/l/shifts/electronic`
- **Price filter flaky:** Sometimes doesn't update results. Filter manually.
- **"Show details" button:** Some listings collapse bike details. Click to expand.
- **INACTIVE listings:** Can't be purchased — filter out.
- **Frameset listings:** Filter out unless explicitly wanted.
- **Cloudflare challenge:** `ERR_ABORTED` / "Just a moment..." page means Cloudflare is blocking automation. The browser window is visible — ask the user to solve the challenge in it, then continue (see *Cloudflare Bot Protection* section at the top).

## Deep-Dive Search Strategy

**Don't stop at one filtered URL.** Most listings are miscategorized or missing filter tags. A thorough search requires multiple passes with different strategies. Aim to collect **50-100 candidate listings** before narrowing down.

### Pass 1: Filtered Searches (Start Here)

Run each URL and extract all visible results. buycycle shows 52 per page — scroll to load more or navigate pagination.

```bash
# Primary: gravel + size L + electronic
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/gravel/frame-sizes/l/shifts/electronic'

# Also size M — some brands' M = 55-56cm, fits 183cm on the upper end
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/gravel/frame-sizes/m/shifts/electronic'
```

### Pass 2: Relax Filters (Catch Miscategorized Bikes)

Some sellers tag bikes incorrectly. Remove one filter at a time:

```bash
# All gravel, electronic, any size (filter manually)
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/gravel/shifts/electronic'

# All gravel, size L, any shifting (some electronic bikes aren't tagged "electronic")
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/gravel/frame-sizes/l'
```

### Pass 3: Cyclocross & All-Road Bikes

Cyclocross bikes are essentially gravel race bikes — same geometry, tire clearance, and often better spec for the price.

```bash
# Cyclocross category
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/cyclocross'

# Triathlon bikes sometimes overlap with gravel
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/triathlon'
```

### Pass 4: Endurance Road Bikes (Gravel-Adjacent)

Modern endurance road bikes fit 35-40mm tires — functionally gravel-capable. Check road bikes with wide clearance.

```bash
# Road bikes with electronic shifting, size L
{browser-tools}/browser-nav.js 'https://buycycle.com/en-nl/shop/main-types/bikes/types/road-gravel/categories/road/frame-sizes/l/shifts/electronic'
```

Look for: Canyon Endurace, Trek Domane, Specialized Roubaix, Giant Defy, BMC Roadmachine, Cervelo Caledonia. These often come with carbon wheels and electronic shifting at better prices than dedicated gravel bikes.

### Pass 5: Pagination / Scrolling

buycycle lazy-loads results. To see more than the first 52:

```javascript
// Scroll to bottom to trigger lazy load
window.scrollTo(0, document.body.scrollHeight);
// Wait, then scroll again
setTimeout(function() { window.scrollTo(0, document.body.scrollHeight); }, 2000);
```

Or check if there's a "Load more" button or pagination links. Extract results after each scroll.

### Pass 6: Check Individual Listings for "Discover Similar Bikes"

Every product page has a "Discover similar bikes" / "Bikes you might also like" section. These are algorithmically recommended and often surface hidden gems. After checking a promising listing, extract the similar bikes section:

```javascript
(function() {
  var t = document.body.innerText;
  var idx = t.indexOf("Discover similar bikes");
  return idx > 0 ? t.slice(idx, idx + 2000) : "not found";
})()
```

### Pass 7: Recently Sold (Reference Pricing)

Check recently sold gravel bikes for price references:

```bash
# Sort by recently sold (use UI: Sort By → change to see recently sold items)
# Or check the API request for sold items
```

### Budget Flexibility

When collecting candidates, **relax the budget to €1,500-5,000**. Include bikes slightly above €4,000 — they may accept offers, or a seller might drop the price. Include bikes slightly below €2,000 — they may have been undervalued. Flag them as "under budget" or "stretch" in the final report.

### Time Commitment

A thorough buycycle deep dive should take **10-15 searches** across categories, with scrolling on high-result pages. Expect to inspect **20-30 individual listings** before narrowing to the top 10-15.

## Results Format

Present findings as a markdown table with: Bike name/year, Price (incl. Buyer Protection), MSRP, Size, Frame material, Groupset, Wheels (carbon? model), Power meter (yes/no), Location, Seller info, Link, Key notes.

buycycle bikes ship **EU-wide**, so there is no fixed distance from Amsterdam — record location as "buycycle (EU ship)" / "📦 EU delivery" so they slot cleanly into a combined ranked list next to Marktplaats listings.

### Building the Combined Overview

After collecting candidates, hand the enriched candidate JSON to the **`/make-overview`** skill to produce a `OVERVIEW.md` with a ranked shortlist across all sources. Save raw per-search JSON, deduped `*_all_unique.json`, and `*_candidates.json` alongside it. See `/make-overview` for the exact format and ranking rules.
