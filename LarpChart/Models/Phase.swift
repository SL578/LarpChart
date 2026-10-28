import Foundation
import SwiftData

/// One snapshot of a plan: where every unit is, the arrows drawn, and the ink.
@Model
final class Phase {
    @Attribute(.unique) var id: UUID
    var name: String
    /// nil for the root. Branching (M14) adds siblings under the same parent.
    var parentPhaseID: UUID?
    /// Rank among siblings: 0 is the main line, 1+ are branches.
    var order: Int
    var unitStates: [UnitState]
    var arrows: [Arrow]
    /// Encoded `PKDrawing`.
    var inkData: Data?
    var plan: Plan?

    init(
        name: String,
        parentPhaseID: UUID? = nil,
        order: Int = 0,
        unitStates: [UnitState] = [],
        arrows: [Arrow] = [],
        inkData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.parentPhaseID = parentPhaseID
        self.order = order
        self.unitStates = unitStates
        self.arrows = arrows
        self.inkData = inkData
    }

    /// A follow-up phase: same unit positions, no arrows or ink
    /// (those describe the move out of `previous`, not into the new phase).
    static func makeNext(after previous: Phase, name: String) -> Phase {
        Phase(name: name, parentPhaseID: previous.id, order: 0, unitStates: previous.unitStates)
    }

    var node: PhaseNode {
        PhaseNode(id: id, parentID: parentPhaseID, order: order)
    }
}
