# LarpChart

Native iPad playbook for airsoft squads. The squad lead sketches a plan on a field map minutes before a round, then steps through it live, phase by phase. Squadmates follow along in a read-only web viewer.

Full spec: `docs/SPEC.md` · Milestones: `PLAN.md` (work only on the current milestone)

## Guiding constraint

The lead has ~2 minutes before a round. Speed beats features. Every common action should take a few taps at most. When in doubt, choose the simpler, faster interaction.

## Stack

- **iPad app:** SwiftUI, iPadOS 17+, Swift 5.9+
- **Persistence:** SwiftData, local-first. The iPad is the source of truth; the app must work fully offline.
- **Ink layer:** PencilKit (freehand notes and zones only)
- **Units and arrows:** custom SwiftUI `Canvas` / views, NOT PencilKit
- **Sync (v0.5+):** Supabase Realtime + Storage. The backend only relays; it never owns plan data.
- **Web viewer (v0.5+):** TypeScript + Vite, no framework, in `web/`
- **Maps (v1+):** MapKit for the optional world-map base layer

## Core data model

All positions are stored in **normalized map-image coordinates** (0–1 on each axis of the field image), never lat/long. Georeferencing (v1) is an optional transform layered on top.

- **Field:** name, map image, optional `GeoTransform` (v1)
- **Plan:** belongs to a Field; owns a tree of Phases; `rootPhaseID`
- **Phase:** `parentPhaseID` (nil for the root; branching uses this), name, order, `[UnitState]`, `[Arrow]`, ink data (`PKDrawing` as `Data`)
- **Unit:** id, type (`UnitType` enum: infantry / mechanized / objective categories), label, optional roster member
- **UnitState:** unitID + position for one phase
- **Arrow:** id, optional `unitID`, `[CGPoint]` path (normalized), style (route / attack / zone edge)
- **Roster:** saved list of named members with default unit types
- **FireLink:** phaseID, shooterUnitIDs, targetUnitID. Per phase, not copied to new phases; one target per shooter per phase.

Rules:
- Arrows are structured objects linked to units. Animation follows an arrow when a unit has one, otherwise a straight line.
- A new phase copies the previous phase's unit positions.
- Keep `parentPhaseID` even before the branching UI exists.

## Project layout

```
LarpChart/
  App/            entry point, root navigation
  Models/         SwiftData models + plain value types
  Features/
    Fields/       field library, image import
    Board/        map canvas, units, arrows, ink, gestures
    Phases/       phase strip, live/presentation mode, animation
    Rosters/
  Shared/         reusable views, icons, helpers
LarpChartTests/
web/              squad web viewer (v0.5+)
docs/SPEC.md
```

## Conventions

- SwiftUI + `@Observable`; no third-party Swift packages without asking first
- Small views: split anything over ~200 lines
- Pure logic (phase tree, coordinate math, animation interpolation) lives outside views and has unit tests
- Finger input must work as well as Apple Pencil (rain, gloves, lost Pencil)
- Tap targets at least 44pt; prefer large controls in live mode
- No GPS, network, or Supabase code before its milestone

## Commands

- Build: `xcodebuild -scheme LarpChart -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)' build`
- Test: same with `test`
- Web viewer (v0.5+): `cd web && npm run dev`

After any change, build and run the tests, and fix errors before reporting back.

## Working agreement

- Plan before coding on anything non-trivial; list the files you'll touch
- Stay inside the current milestone; put new ideas in `docs/BACKLOG.md` instead of building them
- When a milestone is done, check it off in `PLAN.md`
