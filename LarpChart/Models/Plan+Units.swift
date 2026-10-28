import Foundation
import SwiftData

/// Placing, moving, and removing units. A unit's identity lives on the plan;
/// its position lives in each phase's `unitStates`.
extension Plan {
    func unit(withID id: UUID) -> PlanUnit? {
        units.first { $0.id == id }
    }

    var rootPhase: Phase? {
        rootPhaseID.flatMap(phase(withID:))
    }

    /// Creates a unit with the next free auto label and places it in `phase`.
    @discardableResult
    func addUnit(_ type: UnitType, at position: NormalizedPoint, in phase: Phase) -> PlanUnit {
        let unit = PlanUnit(type: type, label: UnitLabels.next(for: type, existing: units.map(\.label)))
        units.append(unit)
        phase.unitStates.append(UnitState(unitID: unit.id, position: position.clamped()))
        return unit
    }

    /// Removes the unit, its position in every phase, and every arrow linked to it.
    func deleteUnit(_ unit: PlanUnit) {
        for phase in phases {
            phase.unitStates.removeAll { $0.unitID == unit.id }
            phase.arrows.removeAll { $0.unitID == unit.id }
        }
        units.removeAll { $0.id == unit.id }
        modelContext?.delete(unit)
    }
}

extension Phase {
    func position(of unitID: UUID) -> NormalizedPoint? {
        unitStates.first { $0.unitID == unitID }?.position
    }

    /// Moves a unit already placed in this phase. Positions are kept inside the map.
    func moveUnit(_ unitID: UUID, to position: NormalizedPoint) {
        guard let index = unitStates.firstIndex(where: { $0.unitID == unitID }) else { return }
        unitStates[index].position = position.clamped()
    }
}

/// Auto labels: the type's short code plus the lowest free number (R1, R2, B1…).
enum UnitLabels {
    static func next(for type: UnitType, existing: [String]) -> String {
        let taken = Set(existing)
        var number = 1
        while taken.contains("\(type.shortCode)\(number)") { number += 1 }
        return "\(type.shortCode)\(number)"
    }
}
