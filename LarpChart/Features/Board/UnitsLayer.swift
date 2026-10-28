import SwiftUI

/// The units placed in one phase, drawn over the map. Drag a unit to move it.
/// Must sit in the `BoardSpace` coordinate space, the same space `imageFrame` is
/// measured in.
///
/// Taps also land here, but the map's tap handler resolves them with
/// `MapGeometry.unit(at:)`, so a unit selects the same way whatever tile is selected.
struct UnitsLayer: View {
    let plan: Plan
    let phase: Phase
    let imageFrame: CGRect
    @Binding var selectedUnitID: UUID?

    /// The unit being dragged and how far it has moved, in view points.
    /// Saved to the phase only when the drag ends.
    @State private var drag: (unitID: UUID, translation: CGSize)?

    var body: some View {
        let unitsByID = Dictionary(plan.units.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        ForEach(phase.unitStates, id: \.unitID) { state in
            if let unit = unitsByID[state.unitID] {
                let point = viewPoint(for: state)
                UnitMarker(type: unit.type, label: unit.label, role: unit.role, isSelected: selectedUnitID == unit.id)
                    .contentShape(Circle().inset(by: -UnitMarker.hitSlop))
                    .position(point)
                    .zIndex(drag?.unitID == unit.id ? 1 : 0)
                    // Same result as the map's tap handler, so it's harmless if both fire.
                    .onTapGesture { selectedUnitID = unit.id }
                    .gesture(moveGesture(for: state))
                    .accessibilityElement()
                    .accessibilityLabel(accessibilityLabel(for: unit))
                    .accessibilityAddTraits(selectedUnitID == unit.id ? .isSelected : [])
            }
        }
    }

    private func accessibilityLabel(for unit: PlanUnit) -> String {
        let name = "\(unit.type.displayName) \(unit.label)"
        return unit.role == .none ? name : "\(name), \(unit.role.displayName)"
    }

    private func viewPoint(for state: UnitState) -> CGPoint {
        let point = MapGeometry.toView(state.position, in: imageFrame)
        guard let drag, drag.unitID == state.unitID else { return point }
        return CGPoint(x: point.x + drag.translation.width, y: point.y + drag.translation.height)
    }

    private func moveGesture(for state: UnitState) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .named(BoardSpace.name))
            .onChanged { value in
                // The action bar would be left behind at the old position.
                if drag == nil { selectedUnitID = nil }
                drag = (state.unitID, value.translation)
            }
            .onEnded { value in
                let start = MapGeometry.toView(state.position, in: imageFrame)
                let end = CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height)
                phase.moveUnit(state.unitID, to: MapGeometry.toNormalized(end, in: imageFrame))
                drag = nil
            }
    }
}
