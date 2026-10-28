# LarpChart — v1 Spec

Oct 28, 2026 · @Stephen Lin

## Overview

LarpChart is a native iPad playbook for airsoft squads: the squad lead sketches a plan on a field map minutes before a game, then runs it live, phase by phase, while squadmates follow along on their phones.

**Core use case:** right before a round, the squad lead pulls up LarpChart on an iPad, draws a quick plan with the squad around them (drawing-board style), and executes it live. As the game unfolds, the lead advances phases or branches to a new plan, and every squadmate's phone updates and alerts them.

The name nods to airsoft as a kind of live-action roleplay, with "Chart" for the map and plan.

## Positioning vs ATAK

LarpChart complements ATAK rather than competing with it. ATAK (and CivTAK/iTAK) is free and already widely used in airsoft and milsim for live GPS tracking and team coordination. What it doesn't do well is the part LarpChart is built around: sketching a plan fast, animating it, and stepping through it live.

- **Pitch:** a playbook for airsoft squads, closer to a football playbook or an esports strategy planner than a tracking tool.
- **GPS:** a supporting feature, not the headline.
- **Long term:** LarpChart becomes the planning front-end for squads that already run TAK (see ATAK export in the roadmap).

## Platforms and architecture

The planner is a native iPad app (no web port), because Pencil drawing feels better in a dedicated app. Squadmates follow along in a web viewer, which keeps sharing simple.

&#91;embedded content: LarpChart architecture · iPad app, sync backend, web viewer\]

The iPad sends plans and phase changes to a live sync backend, which pushes them to every squadmate's browser; ATAK export comes later.

## v1 feature set

The v1 loop is: load the field map, sketch phases, share a link, and step through phases live.

**Maps**

- World map base layer, optional (indoor and close-quarters courses don't need it)
- Upload an arena map image and overlay it on the world map
- Georeference the overlay by pinning 2–3 points on the image to points on the map, then scale and rotate
- Lock the map so drawing over it never moves it
- Save field maps for reuse on game day

**Icons**

| Category | Examples |
| --- | --- |
| Infantry | Rifleman, breacher, sniper, medic |
| Mechanized | Logistics, gun trucks, helicopters (for fancy arenas) |
| Objectives & Terrain | Flags, bomb sites, spawn points, cover and barricades, doors and breach points, enemy contacts |

**Drawing**

- Apple Pencil drawing: arrows, routes, zones, freehand notes
- Drag-and-drop icons
- Saved squad rosters so units are ready to place

**Phases and live play**

- Phase-based plans with animated transitions between phases
- Live branching from the current phase
- Web viewer for squadmates, with change-of-plan alerts

**GPS**

- Optional live position of the squad lead and squadmates on the map (own team only)

## Phase system, animations, live branching

Plans are a sequence of phases (Phase 1, 2, 3…), each a snapshot of where every unit is and what's drawn. Phases are coarse keyframes, so the full keyframe timeline later builds on this system instead of replacing it.

**Animations**

- Moving between phases slides each unit from its old position to its new one
- Units follow the arrow drawn for them where one exists, otherwise a straight line
- Mainly for glamor in v1, but it also makes the plan easier to read at a glance

**Live control**

- The squad lead controls the clock: "Next phase" and "Hold" buttons, not auto-play
- Advancing a phase updates every squadmate's viewer

**Branching**

- When the plan doesn't go to plan, the lead branches off the current phase into a new route ("Plan B")
- Plans form a tree: the original stays intact, so the lead can jump back if the original route opens up again
- Target flow: long-press the current phase → Branch → drag a few icons → Send, in a few taps
- Squadmates get a change-of-plans alert when a branch is sent
- The tree doubles as an after-action review: what was planned vs. what actually happened

## Squad web viewer and notifications

Squadmates follow the plan through a web page, not an app: they only watch, and a link is the lowest-friction way to get a whole squad on board.

- The lead shares a link (or QR code) from the iPad
- The viewer shows the map, the current phase, unit positions, and animations between phases
- It updates live when the lead advances a phase or sends a branch
- **Alert caveat:** a plain web page can't send push notifications or vibrate on iPhone. Squadmates need to add the viewer to their home screen as a web app to get push alerts on newer iOS versions. Test this early, since change-of-plan alerts are the point of branching.

## Design principles and constraints

The lead has about two minutes before a round, so speed beats features everywhere.

- **Fast over deep:** arrows plus phases may be all that's needed on game day; nothing should take more than a few taps
- **Native drawing:** a dedicated app, because Pencil drawing feels better there than in a browser
- **Bad signal is normal:** fields are often in the woods with spotty cell service, so preload field maps and plan for offline use early
- **GPS is coarse:** phone GPS is accurate to a few meters and often fails indoors, so the app must work fully as a drawing board without it
- **Fair play:** live tracking shows your own team only; check with field owners before shipping it

## Future roadmap

After v1, in rough order:

1. **Full keyframe timeline:** in-between keyframes on top of phases, plus real-time playback
2. **Custom iconography:** upload your own icons
3. **ATAK export:** export phases as KML/KMZ layers or data packages that squads toggle through in ATAK/iTAK (static snapshots, no animation)
4. **Offline sync:** share plans over local Wi-Fi or Bluetooth when there's no internet
5. **Richer multiplayer:** deeper squad coordination beyond view-and-follow

## Open questions and risks

- [ ] Will squadmates actually add the viewer to their home screen for alerts? If not, what's the fallback?
- [ ] How smooth can georeferencing feel? It's the hardest part of the MVP to get right.
- [ ] Do field owners allow live position tracking during games?
- [ ] Pilot: could Thunder Kiss NW's upcoming killhouse and league be the first test field, with its arena map preloaded?
- [ ] Which backend for live sync (Supabase vs Firebase)?
