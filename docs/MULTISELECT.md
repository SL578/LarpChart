# Multi-select: plan

**Status:** plan only, not built. Written during M3 (Oct 28, 2026).

**Goal:** the squad lead drags a box over several units, then moves, deletes, or sets a role on all of them at once, in a few taps.

## Where things stand (M3)

- **Selection:** the map's tap handler finds the tapped unit with `MapGeometry.unit(at:)`. Selection is `selectedUnitID: UUID?` in `BoardEditor`.
- **Drag a unit:** moves it, starting after 2pt of movement.
- **Tap a unit:** opens the action bar (Role / Rename / Delete). Long-pressing a unit does nothing, so the box gesture is free to use it later.
- **One-finger drag on empty map:** pans, unless the map is locked.
- **Pinch:** zooms. **Double-tap:** zooms, except on a unit.
- **Tap a tile, then tap the map:** places units.

Every multi-select gesture has to fit around these without slowing any of them down.

## 1. Starting a selection drag

### Options

**A. Long-press empty map, then drag (recommended)**
Hold a finger still on empty map for about 0.25s. The box starts there and follows the finger.
- **Map panning:** a pan only starts once the finger moves, so holding still can't be mistaken for one. It works the same whether the map is locked or unlocked, so there's nothing new to learn.
- **Dragging a unit:** the box only starts if the long-press lands on empty map (`unit(at:)` returns nil). A long-press on a unit does nothing.
- **Cost:** a 0.25s hold before every box. There's no mode to turn on or off, so you can't get stuck in the wrong one.

**B. A Select mode button**
A button at the top of the palette turns on select mode. In that mode, a one-finger drag on the map draws a box and two fingers pan.
- **For:** easy to discover, no delay, no gesture-timing risk.
- **Against:** an extra tap on and off. Leaving it on by mistake breaks one-finger panning, and when a mode silently changes what dragging does, that costs time on game day.

**C. On a locked map, a plain drag on empty map draws a box**
When the map is locked, a one-finger drag on empty map draws a box straight away. When it's unlocked, the drag pans as it does now.
- **For:** the fastest option. A locked map has no use for a one-finger drag anyway.
- **Against:** the same drag means two things depending on the lock, and unlocked maps still need A or B.

**Recommendation:** build A. If the field test (M9) shows the hold is too slow, add C on top: a locked map skips the hold. A and C fit together; B doesn't fit either.

### Fitting with M4 (arrows) and M5 (ink)
- **Arrows (M4):** routes start from a unit. Boxes always start on empty map, so the two never compete. M4 still has to decide how drawing a route from a unit differs from moving the unit (for example, an arrow mode or a handle on the selected unit). Multi-select doesn't affect that choice.
- **Ink (M5):** in ink mode, PencilKit gets every touch, so there's no box. Entering ink mode clears the selection.

### Finger vs. Apple Pencil
In units-and-arrows mode, finger and Pencil work exactly the same, as CLAUDE.md requires. No Pencil-only shortcut, so a lost Pencil or gloves change nothing. If testing shows a need, a Pencil-only extra could be added later, such as a Pencil drag that skips the hold.

### Implementation sketch
- **The gesture:** `LongPressGesture(minimumDuration: 0.25).sequenced(before: DragGesture(minimumDistance: 0))` on the map's `ZStack`. It only starts if the press point isn't on a unit.
- **No panning during a box:** while a box is active, the map's pan ignores the drag. `panAndZoom` checks a `isMarqueeActive` flag. A second finger cancels the box.
- **Fallback:** if SwiftUI can't keep the long-press and the pan apart reliably, use a `UILongPressGestureRecognizer` (it keeps reporting movement after it fires) through a `UIViewRepresentable`. `UIGestureRecognizerRepresentable` isn't an option because it needs iOS 18 and the app targets 17.

## 2. How selected units look, and adding or removing one

- **Look:** the same highlight as a single selection (thicker white ring, 1.12× scale), so there's only one look to learn.
- **While dragging a box:** a translucent rectangle with an accent-colored border. Units inside it get the selected look live, before you lift.
- **Selection state:** `none`, `single(id)`, or `multi(Set<UUID>)`.
  - Tapping a unit in `none` or `single` selects just that unit, as it does today.
  - Tapping a unit in `multi` adds or removes it. If that leaves no units, the selection becomes `none`. If it leaves one, it stays `multi`, so the next tap still adds instead of replacing.
- **A second box while a selection exists:** replaces the selection. A box that adds to it is an option for later, but not now.
- **Quick placement:** while a tile is selected, a tap on empty map still places a unit. Taps on units follow the rules above.

## 3. Actions on a selection, and where they appear

**Action bar:** the same slim capsule as today, centered above the box around the selected units, clamped to the screen, and flipped below if there's no room above.

| Control | What it does |
|---|---|
| **Role ▾** | A menu with None / Squad Lead / Fireteam Lead, applied to every selected unit. A checkmark shows only if they all share a role. |
| **Delete (n)** | Shows a confirmation dialog: "Delete 5 units?". It's one extra tap, but there's no undo yet and a multi-delete can wipe out a formation. A single delete stays instant. |
| **✕** | Clears the selection. |

- **No Rename:** there's no single label to set. The bar shows how many units are selected, for example **5 selected**, so units hidden under the palette or off screen aren't a surprise.
- **Moving together:** drag any selected unit and every selected unit moves the same distance, so the formation keeps its shape.
  - The distance is limited so the unit nearest each map edge stops at that edge, instead of each unit being clamped on its own, which would squash the formation.
  - All the moves are saved at once when you let go.
  - The action bar hides while you drag.
- **All unit actions stay in the tap action bar,** as in M3: no long-press menu on units.

## 4. Clearing the selection

- Tap empty map (with no tile selected, as now)
- Tap ✕ in the action bar
- After a delete
- When switching phase (M6), entering ink mode (M5), or leaving the board

Placing a new unit also clears the selection, as it does today.

## 5. Data and state

- **Not saved:** the selection lives only in `@State` in `BoardEditor`. It doesn't touch SwiftData or the sync format.
- **Pure logic in `Features/Board/UnitSelection.swift`**, with unit tests:
  - `units(in rect: CGRect, states:, imageFrame:) -> Set<UUID>`. A unit counts if its center is inside the box, measured in view space.
  - `toggling(_ id:)`, which follows the state rules in section 2.
  - `groupTranslation(_ translation:, positions:) -> NormalizedPoint delta`, which keeps the formation inside 0–1.
  - Clearing out units that no longer exist (deleted while selected).
- **`Plan` needs batch helpers:** `moveUnits([UUID: NormalizedPoint], in:)`, `deleteUnits(_:)`, and `setRole(_:for:)`, all tested. They're thin loops over the existing single-unit functions.

## 6. Edge cases

- **Zoomed in:**
  - The box is drawn in view space and checked against on-screen unit positions, so only units you can see get selected.
  - The box doesn't auto-pan when you reach the screen edge, to keep it simple. Zoom out first to select a wider area.
  - A pinch during a box drag cancels the box.
- **Units under the palette:** the box can't start on the palette, because the palette takes those touches. But a box drawn next to it covers units underneath, and they do get selected. The "n selected" count makes that visible. To move them, drag a selected unit you can see, or collapse the palette.
- **An empty box:** selects nothing and clears any previous selection, like tapping empty map. It doesn't open an action bar.
- **A box around one unit:** becomes `multi` with one unit (not `single`), so taps keep adding. It shows the multi action bar, without Rename.
- **A selected unit disappears** without the selection's Delete (for example, the current phase changes underneath it): it's removed from the selection. If none are left, the selection becomes `none`.
- **A very short hold or tiny box** (under about 8pt): treated as a tap, so it neither selects nor clears.
- **VoiceOver:** a box can't be drawn by gesture. Each unit gets an "Add to Selection" accessibility action, and the action bar works the same way.

## 7. Proposed PLAN.md entry (not added)

> - [ ] **M6.5. Multi-select**
>   Long-press empty map and drag a box to select several units; tap to add or remove one. Move the group together (formation stays inside the map), set a role, or delete (with a confirmation). Selection is view state only. Box math, toggling, and group clamping are unit-tested. See `docs/MULTISELECT.md`.
>   *Done when:* you can select a 5-unit fireteam and move it to a new spot in under 3 seconds, map locked or unlocked, finger or Pencil.

**Why after M6:**
- By then the arrow gestures (M4) and ink mode (M5) exist, so the box gesture can be checked against the real thing instead of guesses.
- Moving many units at once matters most when adjusting positions phase by phase (M6).
- If you'd rather have it sooner, it also works as **M3.5**, but it would need re-checking after M4 and M5.
