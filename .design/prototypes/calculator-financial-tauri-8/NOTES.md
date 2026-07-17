# NOTES — The Mechanism Computes (calc-fin-tauri-8)

Disposable Studio-direction prototype. Single self-contained `index.html`
(inline CSS + inline JS + inline SVG), no build step, no dependencies. Open
the file directly in a browser to evaluate. All financial output is
placeholder math (a plain standard amortization formula) wired only for
interaction testing — it is not the certified calculation engine, and
nothing is persisted.

## How the shell is built

- The flat, linear form (Function list, Mode list) is always present in the
  DOM and always operable; it is the baseline. The concentric-ring dial is a
  progressive-enhancement overlay drawn in the same 256×256 CSS-px space.
- Ring segments are plain HTML `div[role=radio]` elements shaped with
  `clip-path: polygon(...)` (a straight-edge trapezoid approximation of the
  donut wedge, not a curved SVG arc). This keeps hit-testing/browser support
  simple while still producing the same inner-edge chord as a true arc,
  because the inner edge of a trapezoid wedge *is* the chord line.
- Purely decorative art (bezel, tick marks, gear teeth, engraving lines) is
  a separate `<svg aria-hidden="true" pointer-events:none>` layer, fully
  behind the interactive layer. Only the plain interactive-layer shapes
  carry ARIA roles and keyboard handlers, per the invariant.
- Every ring/segment label renders on the segment's own opaque solid fill
  (`paper.200`, or `amber.500` when selected) — never on the gear/engraving
  texture underneath.

## Risk 1 — Radial discoverability + rapid entry vs. flat view

**Concern.** A first-time user doing the loan/amortization flow is not
guaranteed to recognize eleven thin wedges around a hub as the primary way
to pick "Loan" + "Monthly" without the visible hint text and the
always-present "Switch to flat view" toggle. The prototype mitigates this
with (a) a persistent, non-modal toggle at the very top of the page so the
flat baseline is one click away at all times, and (b) a static instruction
line under the dial. It does **not** include any first-run coach-mark or
animated affordance, and that is a real gap for a production build.

**Recommended adjustment.** Before full engineering, run a short moderated
check specifically on first-contact discoverability (do users find the dial
without being told it's clickable, and do they know the flat toggle
exists). If discoverability is weak, add a one-time, dismissible,
reduced-motion-safe affordance (e.g., a static "Try the dial" label near the
toggle) rather than an animated pulse.

## Risk 2 — Keyboard focus order + rectangular focus indicator

**Pass.** Each ring is `role="radiogroup"` with roving `tabindex` (exactly
one segment per ring is a tab stop at a time; the group itself is one tab
stop in the page's tab order). Arrow keys move focus *and* selection within
a ring, matching the standard single-select radiogroup pattern; Home/End
jump to first/last; Space/Enter also confirm the focused segment. Tab order
is: skip link → view toggle → (flat list, if visible) → Function ring (one
stop) → Mode ring (one stop) → hub → loan fields → crank → compute/reset →
result.

The focus indicator is implemented as a **separate, unclipped sibling
element** per segment (`.segment-focus-ring`), positioned to the exact
bounding rectangle of the segment but never given the segment's
`clip-path`. JS toggles an `is-focused` class on `focusin`/`focusout`. This
guarantees the ring is always an axis-aligned rectangle — it cannot follow
the wedge's arc, because it is never clipped to the wedge shape. It renders
as: inner 2px `lacquer.950` keyline flush with the bounding box, a 2px
transparent gap, then an outer 2px `focus.100` keyline (built with three
stacked, unblurred `box-shadow` layers, a technique that does not depend on
animation or transitions, so it is unaffected by `prefers-reduced-motion`).
The same technique is applied to the circular hub button via its own
unclipped overlay, so its keyline is also rectangular rather than circular.
Plain rectangular controls (buttons, text inputs, flat radio chips) get the
same three-layer box-shadow directly, no overlay needed.

**Implementation note for engineering.** This costs one extra DOM node per
focusable ring segment (30 nodes total for 15 segments). That is acceptable
for a prototype; a production component library should evaluate whether an
SVG `filter`/mask-based approach can achieve the same non-clipped rectangle
with fewer nodes.

## Risk 3 — 24×24 CSS-px hit-target chord math

**Pass, tight margin.** Geometry is fixed and non-scaling (see Risk 4):
dial diameter 256 CSS px, hub r0–48, Function band r48–88 (11 segments),
Mode band r88–128 (4 segments).

- Function-ring narrowest chord (at the inner r=48 edge, the tightest point
  of any wedge): `2 × 48 × sin(180°/11) ≈ 27.0px`.
- Mode-ring narrowest chord (inner r=88 edge): `2 × 88 × sin(180°/4) ≈
  124.5px`.
- **Narrowest rendered chord recorded: 27.0px** (Function ring), which
  clears the 24px CSS-px minimum but with only ~3px of margin.

The prototype includes a live "Measure narrowest rendered hit target"
button (Engineering diagnostics panel) that re-measures this from the
actual rendered `dial-stage` bounding box at runtime, so the number can be
re-checked at any browser zoom level or OS text-scaling setting rather than
trusted as a static claim.

**Recommended adjustment.** Because the margin over the 24px floor is thin,
engineering should either (a) enforce a hard-floor minimum rendered dial
diameter of ~256px and never allow any intermediate CSS scaling of the dial
(the prototype already does this — see Risk 4), or (b) if a future design
iteration adds more than 11 function segments, increase the Function band's
inner radius or move to a two-tier / progressive-disclosure menu instead of
packing more wedges into the same band.

## Risk 4 — 400% zoom / reflow

**Pass.** The dial is never fluid-scaled. `.dial-stage` is a fixed 256×256
CSS-px box. A single CSS breakpoint at `max-width: 480px` (well clear of
the ~320 CSS-px effective viewport used for WCAG 1.4.10 400%-zoom testing)
swaps the entire ring-dial region out and shows the always-present flat
linear fields instead — a full replacement, not a shrink. The view toggle
button is hidden at that width since the flat form is already forced. No
element in the page has a fixed width wider than the dial (256px) or the
`.field-row` max width (22rem, itself block-level and wrapping), so no
horizontal scrolling is introduced at any zoom level up to and including
400%.

**Recommended adjustment.** None required functionally; engineering should
just confirm the 480px breakpoint number against the target app's real
chrome/toolbar overhead so the swap reliably happens before any partial
dial clipping could occur in the production shell (Tauri window chrome
differs from a browser tab).

## Risk 5 — Gear-train streaming recompute vs. aria-live twin

**Pass, with a documented mitigation.** The crank is a real `input[type=
range]` (drag, Arrow keys, Page Up/Down, Home/End all work natively) paired
bidirectionally with a real `input[type=number]`; both call the same
`onCrankInput` handler and stay numerically in sync on every `input` event.

On every crank input, three things happen **synchronously, in the same
handler, every time**: the numeric mirror field updates, the decorative
gear's rotation custom property updates (skipped entirely when
`prefers-reduced-motion: reduce` is set), and the **visible** payoff-time
result text updates. None of that is throttled, so a sighted user watching
the gear and the visible numbers never sees them drift out of sync.

The dedicated `aria-live="polite"` announcement (`#crank-live`) is
intentionally **debounced 260ms** after the last change. This is a
deliberate mitigation for a known real-world screen-reader problem: firing
a new `aria-live` announcement on every single `input` event during a fast
drag floods the announcement queue and effectively produces *stale*
announcements (the SR is still reading an old value while several newer
ones have already superseded it). Because the debounce callback always
reads `state.pendingAnnouncement` — which is recomputed fresh on every
input event — at *fire* time, the announcement that eventually reaches the
user is always the true, settled, current value, never an intermediate
stale one, even though it is not spoken on every keystroke of the drag.

**Recommended adjustment.** The 260ms figure is a placeholder starting
point, not a validated number. Engineering should verify actual behavior
with NVDA, JAWS, and VoiceOver under a fast real drag and tune the debounce
window (or switch to an explicit "settle" trigger such as `change` plus a
throttled `input` announcement) based on that evidence before shipping.

## Hard invariants — status

- No native `alert`/`confirm`/`prompt`/`window.*` dialogs and no
  `beforeunload` anywhere in the file. The reset confirmation is an
  app-owned `role="dialog" aria-modal="true"` with `aria-labelledby` +
  `aria-describedby`, a Tab/Shift+Tab focus trap, Escape = Cancel, Cancel
  has initial focus, and focus restores to the button that opened it on
  close.
- Central result readout: `lacquer.950` (#0B0A08) text on `parchment.100`
  (#EDE3CC) background — computed contrast ≈ 15:1, clears the ≥7:1
  requirement by a wide margin.
- Ring/segment labels: `bronze.900` (#4A3B23) text on `paper.200`
  (#DCD5C3) backing plate — computed contrast ≈ 7.4:1, clears the ≥4.5:1
  requirement.
- Focus indicator: inner keyline is `lacquer.950`, which alone is high
  contrast (>>3:1) against both the segment fill and the page background,
  so the ≥3:1 requirement is met regardless of the outer pale ring's own
  contrast against any particular backdrop.
- `prefers-reduced-motion: reduce` removes the hub "turn the mechanism"
  spin animation and freezes the gear's rotation entirely (the JS simply
  stops writing the `--gear-angle` custom property). No information is
  lost: the extra-payment value and the payoff result are always available
  as plain text (`#crank-number`, `#result-payoff`, `#crank-live`)
  independent of whether the decorative gear ever moves.
- Numerals use `font-variant-numeric: tabular-nums` on all inputs and the
  result readout, right-aligned for decimal alignment. Results re-render as
  plain text on every recompute — no odometer/scrolling-digit effect.

## Known prototype limitations

- Math is a single standard amortization formula reused for all 11
  "Function" labels; only the Mode selection (payment-period count)
  actually changes the arithmetic. Function selection is otherwise
  contextual/label-only, clearly marked as placeholder.
- No persistence, no settings, no history, no real currency localization.
- Trapezoid `clip-path: polygon()` approximation is used instead of true
  SVG arcs for the interactive hit layer (see "How the shell is built"). If
  engineering wants a visually curved wedge boundary, that curve should
  live only in the decorative SVG layer underneath, exactly as this
  prototype already does — the interactive layer's shape is a UX/hit-target
  decision independent of the decorative rendering.
- Tested only against modern evergreen rendering behavior (Chromium/Firefox/
  Safari-class `clip-path: polygon()`, CSS custom properties, and
  `:focus-visible` support). No automated cross-browser or screen-reader
  pass was run as part of this prototype; the browser-validator/verifier
  stages should exercise Risks 2 and 5 with real assistive technology.
