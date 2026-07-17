# Remediation addendum: calculator-financial-tauri-8 — visual fidelity (J-001..J-005)

Status: Approved

Approved: 2026-07-16
Approver: user, via orchestrator

task_id: calc-fin-tauri-8
plan_id: calculator-financial-tauri-8-visual-remediation
parent_plan: `docs/plans/calculator-financial-tauri-8.md` (Status: Approved 2026-07-15)

This addendum recommends work. It does not grant execution authority. No engineering writer may start work against it until the user gives explicit approval of THIS addendum. This is a bounded VISUAL remediation addendum to the already-approved parent plan; it references the parent plan and does not restate its contents. The parent plan's engineering invariants (Sections 5.1/5.2) are preserved, not superseded.

## 1. Outcome and trigger

Raise the shipped Tauri calculator's rendered fidelity to the approved "The Mechanism Computes" (Antikythera, bronze/parchment/lacquer) Studio direction by closing five `VISUAL_REVIEW` judge findings (J-001..J-005). Implementer/audience: T2 engineering. This remediation exists because the shipped visuals were a code-writer's thin-line approximation of a text/code description; the deliverables below are literal so no reinterpretation is required.

The remediation was independently triggered by:

- a Codex `VISUAL_REVIEW` judge REVISE verdict, and
- the user's direct statement that the app is far from prototype fidelity.

## 2. Scope and non-goals

**In scope:** only the design changes closing J-001..J-005 in:

- `H:\CommandCenter\orchestrator\calculator-financial-tauri-8\index.html` (CSS `<style>` block plus `:root` tokens)
- `H:\CommandCenter\orchestrator\calculator-financial-tauri-8\main.js` (replace the `buildDecorative()` body, ~L117, and the `buildGear()` body, ~L142)

**Non-goals:** no new features, no journey/IA/flow change, no calculation-engine change, no re-opening of the parent plan.

**No-touch boundary (hard):** do not read, reference, or modify any other `calculator-*` folder.

**Preserved-invariants statement:** every accessibility invariant that already passed review — focus keylines, hit-target chord minimums, backing-plate contrast ratios, reduced-motion behavior — must be preserved by every change in this addendum and never regressed. Section 6 below lists these explicitly.

## 3. Root-cause finding

The shipped build's `main.js` `buildDecorative()` (~L117) and `buildGear()` (~L142) are near-identical to the disposable Studio prototype's own thin-line placeholder art (sparse `<circle>`/`<line>` primitives). Neither the shipped app nor the prototype ever contained a credible bronze mechanical asset. This is an asset-production gap, not an engineering-fidelity gap.

Existing verified anchors used by this remediation:

- token block at `index.html` `:root` (L12-71)
- `.segment-hit` / `.segment-label` (~L227-247)
- `.app-header` / `.tab-nav` (~L95-139)
- BASIC surfaces `.display` / `.keypad` / `.controls` / `.memory-display` (~L292-348)
- global `:focus-visible` (~L85-91)
- dial DOM (~L568-579), hub `#hub-compute` (~L574)
- reused helpers: `svgEl(tag, attrs)` (~L111), `polar(cx, cy, r, deg)` (0deg = up, clockwise) (~L107), constants `CX = CY = 128` (~L102)

## 4. Findings-to-changes map

| Finding | Severity | Owner | Change |
|---|---|---|---|
| J-001 | Major | asset-art-director | `buildDecorative()` full rewrite: bronze bezel gradient, 120 minute + 24 major ticks, 8 aligned spokes, stroke-only non-occluding hub |
| J-002 | Major | asset-art-director | `buildGear()` full rewrite: bronze gradient gear, 12 filled polygon teeth, rim highlight, 5 web spokes, domed hub/axle/specular, amber rim marker, static meshing gear `#gear-context` |
| J-003 | Major | visual-system-designer | `.segment-label` opaque nameplate + new plate tokens (12px, 3.05em pill, ~4.0px corner margin) |
| J-004 | Minor | visual-system-designer | `.tab-nav` inactive/active tab tokens (7.4:1 / 8.5:1 on bronze header) |
| J-005 | Minor | visual-system-designer | `#basic-mode` frame + recessed display/memory windows + beveled keycaps + focus-keyline override (WCAG 2.4.7/2.4.13 regression fix) |

## 5. Literal specification (verbatim; copy-paste-ready)

Reproduce all code below exactly as written. Its literalness is the point of this remediation: engineering must copy it in with zero reinterpretation.

### 5.1 New tokens (add to existing `:root`; no existing token altered)

```css
--color-tab-inactive: var(--paper-200);        /* #DCD5C3 -> 7.4:1 on bronze-900 header */
--color-tab-active:   var(--parchment-100);     /* #EDE3CC -> 8.5:1 on bronze-900 header */
--color-label-plate:      var(--lacquer-950);   /* #0B0A08 opaque plate */
--color-label-plate-text: var(--parchment-100); /* #EDE3CC -> 15:1 text vs plate */
--color-label-plate-edge: var(--bronze-900);    /* #4A3B23 bezel keyline */
```

Decorative-only primitive hexes used directly by the SVG asset code (aria-hidden layers; no WCAG text check applies): bronze-lit `#E8C87A`, bronze-highlight `#C9A24B`, bronze-mid `#8A6A34`, bronze-shadow `#3A2C18`, bronze-engrave `#2E2312`, verdigris `#4E8C7D` / `#5E7E6B`, amber `#E0A438` (existing token).

### 5.2 J-003 — dial segment labels

Replace the `.segment-hit` / `.segment-label` rules with:

```css
.segment-hit {
  position: absolute; inset: 0; pointer-events: auto; cursor: pointer;
  background: var(--paper-200); color: var(--bronze-900);
  font-variant-numeric: tabular-nums;
}
.segment-hit.is-selected { background: var(--color-accent); color: var(--color-on-accent); }
.segment-label {
  position: absolute;
  transform: translate(-50%, -50%);
  pointer-events: none;
  box-sizing: border-box;
  width: 3.05em;
  text-align: center;
  font-size: 12px;
  line-height: 1.1;
  font-weight: 700;
  letter-spacing: 0.01em;
  font-variant-numeric: tabular-nums;
  color: var(--color-label-plate-text);
  background: var(--color-label-plate);
  border: 1px solid var(--color-label-plate-edge);
  border-radius: 3px;
  padding: 1px 4px;
}
.segment-hit.is-selected .segment-label { border-color: var(--color-accent); }
```

Fit proof: label center fixed at mid-radius r=68; worst off-axis segment mid-angle 22.5deg; corrected pill 36.6px wide x ~17.2px tall gives worst outer corner r~=83.68 vs wedge polygon boundary r~=87.7, a ~4.0px margin, recurring identically at all 8 off-axis segments. `.segment-hit` hit rectangle/clip-path/`pointer-events:auto` and the JS-set label center are untouched. Contrast: label/plate 15:1 both states; plate/wedge 13.5:1 unselected, 9.0:1 selected.

### 5.3 J-004 — header inactive tabs

```css
.tab-nav button {
  padding: var(--space-3) var(--space-4);
  background: transparent;
  border: none;
  border-bottom: 2px solid transparent;
  color: var(--color-tab-inactive);
  opacity: 1;
  cursor: pointer;
  font-size: 1rem;
}
.tab-nav button[aria-selected="true"] {
  color: var(--color-tab-active);
  border-bottom-color: var(--color-accent);
  font-weight: 600;
}
```

Contrast: inactive 7.4:1, active 8.5:1 vs `#4A3B23`. Amber underline plus weight-600 active affordance preserved.

### 5.4 J-005 — BASIC mode unification

Add the frame rule; extend the surface rules; add the focus override (finding 1 fix); state hover literally:

```css
#basic-mode {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--space-4);
}
.display {
  background: var(--lacquer-950);
  border: 2px solid var(--color-border);
  padding: var(--space-4);
  border-radius: var(--radius-md);
  font-size: 2.25rem;
  font-family: 'Courier New', monospace;
  text-align: right;
  word-break: break-all;
  min-height: 4rem;
  display: flex; align-items: center; justify-content: flex-end;
  margin-bottom: var(--space-4);
  color: var(--parchment-100);
  font-weight: bold;
  overflow: hidden;
  box-shadow: inset 0 2px 4px rgba(11, 10, 8, 0.55);
}
.keypad button, .controls button {
  padding: var(--space-4);
  font-size: 1.1rem;
  background: var(--color-surface);
  color: var(--color-text);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  cursor: pointer;
  min-height: 44px; min-width: 44px;
  box-shadow: inset 0 -2px 0 rgba(74, 59, 35, 0.35);
}
/* FINDING 1 FIX: restore the dual-tone focus keyline on the most-used surface.
   .keypad button (0,0,1,1) outranks bare :focus-visible (0,0,1,0), so the resting
   bevel was replacing the keyline on keyboard focus (WCAG 2.4.7/2.4.13 regression).
   This override (0,0,2,1) re-layers the exact keyline above the bevel. */
.keypad button:focus-visible,
.controls button:focus-visible {
  box-shadow:
    inset 0 -2px 0 rgba(74, 59, 35, 0.35),
    0 0 0 2px var(--focus-ring-inner),
    0 0 0 4px transparent,
    0 0 0 6px var(--focus-ring-outer);
}
.keypad button:hover, .controls button:hover { background: var(--parchment-100); }
.keypad button.op    { background: var(--color-accent); color: var(--color-on-accent); font-weight: 700; }
.keypad button.equals { background: var(--success-600); color: #fff; grid-column: span 2; }
.memory-display {
  padding: var(--space-3);
  background: var(--color-backing-plate);
  color: var(--color-text-on-plate);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  margin-bottom: var(--space-3);
  display: flex; justify-content: space-between;
  box-shadow: inset 0 1px 3px rgba(11, 10, 8, 0.5);
}
```

Focus-collision audit: global `:focus-visible` (`index.html:85-91`) is NOT edited. `.display` (`role=status`, no `tabindex`) and `.memory-display` (plain div) are NOT focusable, so their inset shadows cannot collide with a focus keyline. Contrast preserved: display 15:1 (>=7:1 target); op 9.0:1; equals 6.4:1.

### 5.5 J-001 — dial decorative layer

Replace the entire body of `buildDecorative()` (`main.js` ~L117; `svg id="dial-decorative"`, `viewBox 0 0 256 256`) with:

```js
function buildDecorative() {
  var svg = document.getElementById('dial-decorative');
  if (!svg) return;
  var defs = svgEl('defs', {});
  var ddBezel = svgEl('linearGradient', { id: 'dd-bezel', gradientUnits: 'userSpaceOnUse', x1: 40, y1: 40, x2: 216, y2: 216 });
  ddBezel.appendChild(svgEl('stop', { offset: 0,   'stop-color': '#E8C87A' }));
  ddBezel.appendChild(svgEl('stop', { offset: 0.5, 'stop-color': '#8A6A34' }));
  ddBezel.appendChild(svgEl('stop', { offset: 1,   'stop-color': '#3A2C18' }));
  defs.appendChild(ddBezel);
  svg.appendChild(defs);
  svg.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 127,   fill: 'none', stroke: '#3A2C18',       'stroke-width': 6,   opacity: 0.9 }));
  svg.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 126,   fill: 'none', stroke: 'url(#dd-bezel)', 'stroke-width': 4 }));
  svg.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 122.5, fill: 'none', stroke: '#E8C87A',       'stroke-width': 1.5, opacity: 0.7 }));
  svg.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 118,   fill: 'none', stroke: '#2E2312',       'stroke-width': 1,   opacity: 0.5 }));
  for (var i = 0; i < 120; i++) {
    var a = i * 3, p1 = polar(CX, CY, 117, a), p2 = polar(CX, CY, 122, a);
    svg.appendChild(svgEl('line', { x1: p1.x, y1: p1.y, x2: p2.x, y2: p2.y, stroke: '#2E2312', 'stroke-width': 0.6, opacity: 0.5 }));
  }
  for (var j = 0; j < 24; j++) {
    var aj = j * 15, m1 = polar(CX, CY, 113, aj), m2 = polar(CX, CY, 124, aj);
    svg.appendChild(svgEl('line', { x1: m1.x, y1: m1.y, x2: m2.x, y2: m2.y, stroke: '#C9A24B', 'stroke-width': 1.75, opacity: 0.85, 'stroke-linecap': 'butt' }));
  }
  svg.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 88, fill: 'none', stroke: '#2E2312', 'stroke-width': 0.75, opacity: 0.40 }));
  svg.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 48, fill: 'none', stroke: '#2E2312', 'stroke-width': 1,    opacity: 0.50 }));
  svg.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 48, fill: 'none', stroke: '#E8C87A', 'stroke-width': 0.5,  opacity: 0.35 }));
  for (var s = 0; s < 8; s++) {
    var as = s * 45, s1 = polar(CX, CY, 48, as), s2 = polar(CX, CY, 128, as);
    svg.appendChild(svgEl('line', { x1: s1.x, y1: s1.y, x2: s2.x, y2: s2.y, stroke: '#2E2312', 'stroke-width': 0.6, opacity: 0.30 }));
  }
  var hub = svgEl('g', { fill: 'none', 'pointer-events': 'none' });
  hub.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 48,   stroke: '#3D2A17', 'stroke-width': 0.6, 'stroke-opacity': 0.55 }));
  hub.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 47,   stroke: '#7A5A32', 'stroke-width': 0.5, 'stroke-opacity': 0.40 }));
  hub.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 46,   stroke: '#E0A438', 'stroke-width': 0.6, 'stroke-opacity': 0.45, 'stroke-dasharray': '1.5 3',   'stroke-linecap': 'round' }));
  hub.appendChild(svgEl('circle', { cx: CX, cy: CY, r: 44.5, stroke: '#4E8C7D', 'stroke-width': 0.5, 'stroke-opacity': 0.30, 'stroke-dasharray': '0.75 4.5', 'stroke-linecap': 'round' }));
  svg.appendChild(hub);
}
```

Notes: the hub region is fill:none, stroke-only (r44-48) so the interactive amber `#hub-compute` face plus label read through (non-occluding). 8 spokes at 45deg align to the real 8-segment Function-ring boundaries. `dial-decorative` host `<svg>` keeps `aria-hidden="true"`, `focusable="false"`, `pointer-events:none`, `z-index:2`.

### 5.6 J-002 — what-if gear

Replace the entire body of `buildGear()` (`main.js` ~L142; `svg id="gear-visual"`, `viewBox 0 0 120 120`) with:

```js
function buildGear() {
  var svg = document.getElementById('gear-visual');
  if (!svg) return;
  var defs = svgEl('defs', {});
  var gBody = svgEl('radialGradient', { id: 'g-body', gradientUnits: 'userSpaceOnUse', cx: 54, cy: 52, r: 46 });
  gBody.appendChild(svgEl('stop', { offset: 0, 'stop-color': '#C9A24B' })); gBody.appendChild(svgEl('stop', { offset: 0.55, 'stop-color': '#8A6A34' })); gBody.appendChild(svgEl('stop', { offset: 1, 'stop-color': '#3A2C18' }));
  defs.appendChild(gBody);
  var gHub = svgEl('radialGradient', { id: 'g-hub', gradientUnits: 'userSpaceOnUse', cx: 58, cy: 57, r: 13 });
  gHub.appendChild(svgEl('stop', { offset: 0, 'stop-color': '#E8C87A' })); gHub.appendChild(svgEl('stop', { offset: 0.6, 'stop-color': '#8A6A34' })); gHub.appendChild(svgEl('stop', { offset: 1, 'stop-color': '#2E2312' }));
  defs.appendChild(gHub);
  var gBody2 = svgEl('radialGradient', { id: 'g-body2', gradientUnits: 'userSpaceOnUse', cx: 108, cy: 92, r: 30 });
  gBody2.appendChild(svgEl('stop', { offset: 0, 'stop-color': '#C9A24B' })); gBody2.appendChild(svgEl('stop', { offset: 0.55, 'stop-color': '#8A6A34' })); gBody2.appendChild(svgEl('stop', { offset: 1, 'stop-color': '#3A2C18' }));
  defs.appendChild(gBody2);
  var gShadow = svgEl('radialGradient', { id: 'g-shadow', gradientUnits: 'userSpaceOnUse', cx: 60, cy: 63, r: 47 });
  gShadow.appendChild(svgEl('stop', { offset: 0.7, 'stop-color': '#0B0A08', 'stop-opacity': 0.35 })); gShadow.appendChild(svgEl('stop', { offset: 1, 'stop-color': '#0B0A08', 'stop-opacity': 0 }));
  defs.appendChild(gShadow);
  svg.appendChild(defs);
  svg.appendChild(svgEl('circle', { cx: 60, cy: 60, r: 47, fill: 'url(#g-shadow)' }));
  var ctx = svgEl('g', { id: 'gear-context' });
  for (var k = 0; k < 8; k++) {
    var c = k * 45 + 22.5;
    var a1 = polar(112, 96, 19, c - 10), a2 = polar(112, 96, 29, c - 6), a3 = polar(112, 96, 29, c + 6), a4 = polar(112, 96, 19, c + 10);
    ctx.appendChild(svgEl('polygon', { points: a1.x + ',' + a1.y + ' ' + a2.x + ',' + a2.y + ' ' + a3.x + ',' + a3.y + ' ' + a4.x + ',' + a4.y, fill: 'url(#g-body2)' }));
  }
  ctx.appendChild(svgEl('circle', { cx: 112, cy: 96, r: 19, fill: 'url(#g-body2)', stroke: '#2E2312', 'stroke-width': 0.75 }));
  ctx.appendChild(svgEl('circle', { cx: 112, cy: 96, r: 6,  fill: 'url(#g-hub)',   stroke: '#2E2312', 'stroke-width': 0.75 }));
  ctx.appendChild(svgEl('circle', { cx: 112, cy: 96, r: 2,  fill: '#0B0A08' }));
  svg.appendChild(ctx);
  var g = svgEl('g', { id: 'gear-rotor' });
  for (var t = 0; t < 12; t++) {
    var ct = t * 30;
    var b1 = polar(60, 60, 34, ct - 7), b2 = polar(60, 60, 44, ct - 4.5), b3 = polar(60, 60, 44, ct + 4.5), b4 = polar(60, 60, 34, ct + 7);
    g.appendChild(svgEl('polygon', { points: b1.x + ',' + b1.y + ' ' + b2.x + ',' + b2.y + ' ' + b3.x + ',' + b3.y + ' ' + b4.x + ',' + b4.y, fill: 'url(#g-body)' }));
  }
  g.appendChild(svgEl('circle', { cx: 60, cy: 60, r: 34, fill: 'url(#g-body)', stroke: '#2E2312', 'stroke-width': 1 }));
  g.appendChild(svgEl('circle', { cx: 60, cy: 60, r: 32, fill: 'none', stroke: '#E8C87A', 'stroke-width': 0.75, opacity: 0.55 }));
  for (var w = 0; w < 5; w++) {
    var aw = w * 72, w1 = polar(60, 60, 12, aw), w2 = polar(60, 60, 31, aw);
    g.appendChild(svgEl('line', { x1: w1.x, y1: w1.y, x2: w2.x, y2: w2.y, stroke: '#2E2312', 'stroke-width': 2.5, opacity: 0.5 }));
  }
  g.appendChild(svgEl('circle', { cx: 60, cy: 60, r: 22, fill: 'none', stroke: '#2E2312', 'stroke-width': 0.75, opacity: 0.4 }));
  g.appendChild(svgEl('circle', { cx: 60, cy: 60, r: 11, fill: 'url(#g-hub)', stroke: '#2E2312', 'stroke-width': 1 }));
  g.appendChild(svgEl('circle', { cx: 60, cy: 60, r: 4,  fill: '#0B0A08' }));
  g.appendChild(svgEl('circle', { cx: 58.4, cy: 57.4, r: 1.4, fill: '#E8C87A', opacity: 0.8 }));
  var rim = polar(60, 60, 39, 0);
  g.appendChild(svgEl('circle', { cx: rim.x, cy: rim.y, r: 3.5, fill: '#E0A438', stroke: '#2E2312', 'stroke-width': 0.75 }));
  svg.appendChild(g);
}
```

Notes: `#gear-rotor` id must be exact and must contain everything that spins (including the amber rim marker at (60,21)). The static meshing gear `g#gear-context` is a sibling appended before `#gear-rotor` (never inside it). No `transform` attribute on `#gear-rotor`: CSS owns `transform:rotate(var(--gear-angle))`, `transform-box:fill-box`, `transform-origin:50% 50%`. `gear-visual` host `<svg>` keeps `aria-hidden="true"`, `focusable="false"`, `pointer-events:none`.

## 6. Preserved engineering invariants

All from the parent plan Section 5.1/5.2; none regressed by this addendum:

- Backing-plate invariant: opaque label plate, text never rendered over texture, contrast >=4.5:1.
- Dual-tone rectangular focus keyline (inner 2px lacquer-950 / 2px gap / outer 2px focus-100, both strokes, never arc-following). This addendum explicitly fixes a regression of this invariant on `.keypad`/`.controls` buttons via the `:focus-visible` override in Section 5.4.
- Central readout contrast >=7:1.
- Ring hit chords >=24px (worst-case ~27px planning floor held; shipped 8-segment Function-ring inner chord 36.7px).
- Crank track >=24px.
- Decorative SVG layers: `aria-hidden`, `pointer-events:none`, non-occluding.
- `#gear-rotor` id and `rotate(var(--gear-angle))` behavior, with an asymmetric rim marker.
- Reduced-motion removes rotation with zero information loss; no indefinite full-energy loop.
- Tabular slashed-zero numerals with plain-text result.
- viewBox-based lossless 400% scaling.
- No native `alert`/`confirm`/`prompt`/`window.*`/`beforeunload` and no new dialog of any kind.
- No other `calculator-*` folder touched.

## 7. Acceptance and validation

After T2 applies the changes, re-validate:

1. Deterministic no-native-dialog source scan still clean.
2. Keyboard-focus each keypad/control button and confirm the dual-tone keyline renders (not the bevel alone); confirm the keyline also renders on segments, hub, tabs, crank.
3. Screenshot all 8 Function-ring labels (TVM, NPV/IRR, Loan, Rates, Bond, Deprec, ROI/BE, FX) and confirm none is corner-clipped.
4. Contrast spot-checks: display 15:1; label/plate 15:1; plate/wedge 13.5:1 unselected / 9.0:1 selected; tabs 7.4:1 / 8.5:1; op 9.0:1; equals 6.4:1.
5. Hit targets: Function-ring inner chord 36.7px; keypad/controls >=44px; crank >=24px.
6. Reduced-motion removes hub spin and gear rotation with no information loss; confirm only the primary gear rotates on crank drag and the meshing gear stays static.
7. Independent Verifier pass, then Browser Validator pass on the rendered webview, per the parent plan's dual-layer approach (Section 9.3).

A Codex `VISUAL_REVIEW` re-check on the new screenshots is recommended (advisory) to confirm the original REVISE findings are closed.

## 8. Design review disposition and override audit trail

The independent design-reviewer's pass 1 substantively verified the specification: all contrast ratios recomputed and matched, all spot-checked SVG coordinates correct, no dangling or duplicate gradient ids, the hub region fully stroke-only and non-occluding, the `#gear-rotor` id preserved with the meshing gear outside it, reduced-motion untouched, no native or new dialog, scope limited to J-001..J-005. Pass 1 returned NEEDS_REVISION with 5 findings.

Revision 1 concretely closed all 5 findings (reflected in the specification in Section 5 above).

The design-reviewer's pass 2 returned NEEDS_REVISION, but on a stage/category error: it checked whether the revised code was already committed to `index.html`/`main.js` and failed the handoff because the code was "not on disk." At this specification-only design/planning stage that is expected and correct: the design fleet is read-only and no engineering has run yet.

The orchestrator/user overrode design-reviewer pass 2 as a stage-mandate error, on the basis of pass 1's substantive verification plus revision 1's concrete closure of all five findings. This override is explicit and recorded here for audit.

## 9. Risks and rollback

Low risk, visual-only, additive to two known code sites plus CSS/token additions. Rollback: revert the `buildDecorative()`/`buildGear()` bodies and the CSS/token additions to their prior state.

This remediation is stale if the parent plan, the token block, or the dial/gear DOM structure materially changes before implementation.

## 10. Approval gate

This addendum requires explicit user approval before T2 may implement any of it. Design specification review status: independently verified sound (pass 1) with all five findings concretely closed (revision 1); pass 2 overridden by the orchestrator/user as a stage-mandate error (Section 8).

Once approved, T2 receives this addendum's path as `ENGINEERING_JOB.approved_plan`, alongside the parent plan path `docs/plans/calculator-financial-tauri-8.md`, for the bounded scope defined in Section 2.
