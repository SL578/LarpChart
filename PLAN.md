# LarpChart — Milestone Plan

One milestone per Claude Code session: `/clear` → plan → build → test → commit → check off here.

## v0 — iPad-only playbook

- [x] **M0. Skeleton**
  Xcode project (iPadOS 17+, SwiftUI, SwiftData), folder layout from CLAUDE.md, git init, `docs/SPEC.md` and `docs/BACKLOG.md` added. Empty sidebar + detail layout.
  *Done when:* app builds and launches in the iPad simulator.

- [x] **M1. Data model**
  SwiftData models for Field, Plan, Phase, Unit, UnitState, Arrow, Roster. Phase-tree helpers (children, path to root, add phase copying the previous one). Coordinate helpers (normalized ↔ view space).
  *Done when:* unit tests cover phase-tree helpers and coordinate math, and pass.

- [ ] **M2. Fields**
  Import an arena map image from Photos or Files. Field library list (create, rename, delete). Board shows the image with pan and pinch-zoom. Lock toggle: when locked, drawing never moves the map.
  *Done when:* you can import a map, zoom around it, lock it, and it's still there after relaunch.

- [ ] **M3. Units**
  Icon palette (infantry, mechanized, objectives and terrain) using placeholder SF Symbols or simple shapes. Drag from palette onto the map; move, label, and delete units.
  *Done when:* placing and moving 10 units feels fast with a finger.

- [ ] **M4. Arrows**
  Draw a route starting from a unit (finger or Pencil) → stored as an Arrow linked to that unit, with light smoothing. Free arrows not tied to a unit. Delete arrows.
  *Done when:* each unit can have a route, and routes persist.

- [ ] **M5. Ink layer**
  PencilKit layer for freehand notes and zones, saved per phase. Clear switch between "units and arrows" mode and "ink" mode.
  *Done when:* ink and units never fight over the same gesture.

- [ ] **M6. Phases**
  Phase strip: add phase (copies previous positions), select, rename, reorder, delete. Each phase keeps its own unit positions, arrows, and ink.
  *Done when:* you can build a 3-phase plan and flip between phases.

- [ ] **M7. Animation + live mode**
  Animate units between phases along their arrow, otherwise in a straight line (interpolation logic unit-tested). Live mode: full-screen board with big **Next phase** and **Hold** buttons; the lead controls the clock.
  *Done when:* stepping through a 3-phase plan in live mode looks smooth.

- [ ] **M7.5. Focus fire**
  FireLink model + tests, create/remove flow, lines and target ring, fade-in after unit animation. See BACKLOG.md "Focus fire".
  *Done when:* you can set 3 shooters on one target in under 10 seconds, and it animates correctly across phases.

- [ ] **M8. Rosters + reuse**
  Saved squad rosters; drop a whole roster onto the map at once. Duplicate a plan. Saved fields ready on game day.
  *Done when:* a fresh plan on a saved field with your roster takes under 2 minutes.

- [ ] **M9. Field test**
  Speed pass: count taps for common actions and cut them. Use it at a real game, then turn findings into backlog items.
  *Done when:* you've used it at an actual game.

## v0.5 — Sharing and web viewer

- [ ] **M10. Supabase setup**
  Supabase project; plan snapshots serialized to JSON; map image uploaded to Storage; row-level security so only the owning iPad can write. Unguessable share IDs.
  *Done when:* the app can publish a plan snapshot and read it back.

- [ ] **M11. Share link**
  Share button → link + QR code. Re-publishing updates the same link.
  *Done when:* a scanned QR opens the right plan URL.

- [ ] **M12. Web viewer**
  `web/` TypeScript + Vite page: map image, units, arrows, current phase, and the same animations. Phone-first layout; read-only.
  *Done when:* it renders a shared plan on an iPhone and an Android phone.

- [ ] **M13. Live updates + alerts**
  Supabase Realtime: phase advances and re-publishes reach viewers live. Change-of-plan alert: screen border flashes yellow, plus a banner naming the new phase. Keep the screen awake where the browser supports it; reconnect and catch up after signal drops.
  *Done when:* 3 phones follow a live run, including one that loses signal and recovers.

## v1 — Branching and geo

- [ ] **M14. Branching UI:** long-press current phase → Branch → move a few units → Send. Tree view of the plan; jump back to the original route. Viewers show branch alerts.
- [ ] **M15. Georeferencing spike:** throwaway prototype pinning 3 points on an image over MapKit. Decide whether it ships in v1.
- [ ] **M16. World map + georeferenced overlay** (if M15 passes)

## v1.x

- [ ] **M17. GPS:** optional own-team positions, coarse, with the app fully usable without it.

## Later (see SPEC roadmap)

Keyframe timeline · custom icons · ATAK KML/KMZ export · offline local-network sync · richer multiplayer
