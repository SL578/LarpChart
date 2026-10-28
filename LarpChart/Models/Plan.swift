import Foundation
import SwiftData

/// A plan drawn on a field: its units and a tree of phases.
@Model
final class Plan {
    @Attribute(.unique) var id: UUID
    var name: String
    var field: Field?
    var rootPhaseID: UUID?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Phase.plan)
    var phases: [Phase] = []

    @Relationship(deleteRule: .cascade, inverse: \PlanUnit.plan)
    var units: [PlanUnit] = []

    init(name: String, field: Field? = nil) {
        self.id = UUID()
        self.name = name
        self.field = field
        self.createdAt = .now
    }

    var phaseTree: PhaseTree {
        PhaseTree(phases.map(\.node))
    }

    func phase(withID id: UUID) -> Phase? {
        phases.first { $0.id == id }
    }

    /// The main sequence of phases, root first.
    var mainLinePhases: [Phase] {
        guard let rootPhaseID else { return [] }
        return phaseTree.mainLine(from: rootPhaseID).compactMap(phase(withID:))
    }

    /// Adds a phase after `previous` (default: the end of the main line), copying its
    /// unit positions. The first phase added becomes the root.
    @discardableResult
    func addPhase(after previous: Phase? = nil, name: String? = nil) -> Phase {
        let name = name ?? "Phase \(phases.count + 1)"
        guard let previous = previous ?? mainLinePhases.last else {
            let root = Phase(name: name)
            phases.append(root)
            rootPhaseID = root.id
            return root
        }

        let insertion = phaseTree.insertion(after: previous.id)
        let next = Phase.makeNext(after: previous, name: name)
        if let childID = insertion.reparentedChildID {
            phase(withID: childID)?.parentPhaseID = next.id
        }
        phases.append(next)
        return next
    }
}
