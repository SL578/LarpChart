import Foundation

/// The parts of a phase the tree helpers need, so they run without SwiftData.
struct PhaseNode: Hashable {
    let id: UUID
    var parentID: UUID?
    var order: Int
}

/// Read-only view of a plan's phase tree.
///
/// A linear plan is a chain: each phase's parent is the phase before it.
/// `order` ranks siblings only: 0 is the main line, 1+ are branches.
struct PhaseTree {
    /// Where a new phase goes when inserted after an existing one.
    struct Insertion: Equatable {
        let parentID: UUID
        let order: Int
        /// The old main-line child, which must be re-parented under the new phase.
        let reparentedChildID: UUID?
    }

    private let nodes: [UUID: PhaseNode]

    init(_ nodes: [PhaseNode]) {
        self.nodes = Dictionary(nodes.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    func children(of id: UUID) -> [PhaseNode] {
        nodes.values
            .filter { $0.parentID == id }
            .sorted { ($0.order, $0.id.uuidString) < ($1.order, $1.id.uuidString) }
    }

    /// The phase itself first, the root last. Stops early on a cycle or a missing parent.
    func pathToRoot(from id: UUID) -> [UUID] {
        var path: [UUID] = []
        var visited: Set<UUID> = []
        var current = nodes[id]
        while let node = current, visited.insert(node.id).inserted {
            path.append(node.id)
            current = node.parentID.flatMap { nodes[$0] }
        }
        return path
    }

    /// The main sequence starting at `root`, following the lowest-order child each step.
    func mainLine(from root: UUID) -> [UUID] {
        var line: [UUID] = []
        var visited: Set<UUID> = []
        var current = nodes[root]
        while let node = current, visited.insert(node.id).inserted {
            line.append(node.id)
            current = children(of: node.id).first
        }
        return line
    }

    /// Insert on the main line right after `id`, pushing its current main-line child down.
    func insertion(after id: UUID) -> Insertion {
        Insertion(parentID: id, order: 0, reparentedChildID: children(of: id).first?.id)
    }
}
