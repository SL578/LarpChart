# LarpChart — Backlog

Ideas that came up outside the current milestone. Review when planning the next one.

## Ideas

- **Replace a field's map image** (keep its plans). Out of M2 scope.
- **Remember zoom/pan per field** across launches. M2 saves only the lock.
- **Rotate the map** (two-finger rotate or a 90° button) for maps drawn off-north.

## Focus fire

**What:** Show which units are concentrating fire on one target during a phase.

**Create (few taps):**
Long-press a target → "Focus fire" → tap each shooter → Done.
Tap a fire line to remove it; long-press the target → "Clear focus fire" to remove all.

**Targets:** any enemy contact or objective icon (bomb site, flag, door/breach point).

**Looks like:** red dashed line from each shooter to the target, plus a
crosshair ring on the target. Thicker ring as more shooters join (2, 3, 4+).

**Data:** `FireLink { id, phaseID, shooterUnitIDs: [UUID], targetUnitID }`
- Belongs to one phase. NOT copied when a new phase is created
  (focus fire is a moment, not a standing order).
- One target per shooter per phase: adding a shooter to a new target
  removes it from the old one.

**Animation:** on phase change, lines fade in after units finish moving.
Removed links fade out first.

**Web viewer:** same lines and ring, read-only.

**Out of scope:** suppression vs. kill distinctions, fire arcs/cones, timing within a phase.
