import Foundation
import Testing
@testable import LarpChart

struct PhaseTreeTests {
    let a = UUID(), b = UUID(), c = UUID(), branch = UUID()

    /// a → b → c on the main line, plus `branch` off a.
    var tree: PhaseTree {
        PhaseTree([
            PhaseNode(id: a, parentID: nil, order: 0),
            PhaseNode(id: b, parentID: a, order: 0),
            PhaseNode(id: c, parentID: b, order: 0),
            PhaseNode(id: branch, parentID: a, order: 1),
        ])
    }

    @Test func childrenAreSortedByOrder() {
        #expect(tree.children(of: a).map(\.id) == [b, branch])
        #expect(tree.children(of: c).isEmpty)
    }

    @Test func pathToRootFromRoot() {
        #expect(tree.pathToRoot(from: a) == [a])
    }

    @Test func pathToRootFromDeepPhase() {
        #expect(tree.pathToRoot(from: c) == [c, b, a])
    }

    @Test func pathToRootFromBranch() {
        #expect(tree.pathToRoot(from: branch) == [branch, a])
    }

    @Test func pathToRootStopsOnCycle() {
        let looped = PhaseTree([
            PhaseNode(id: a, parentID: b, order: 0),
            PhaseNode(id: b, parentID: a, order: 0),
        ])
        #expect(looped.pathToRoot(from: a) == [a, b])
    }

    @Test func pathToRootOfUnknownIDIsEmpty() {
        #expect(tree.pathToRoot(from: UUID()).isEmpty)
    }

    @Test func mainLineSkipsBranches() {
        #expect(tree.mainLine(from: a) == [a, b, c])
    }

    @Test func mainLineStopsOnCycle() {
        let looped = PhaseTree([
            PhaseNode(id: a, parentID: b, order: 0),
            PhaseNode(id: b, parentID: a, order: 0),
        ])
        #expect(looped.mainLine(from: a) == [a, b])
    }

    @Test func insertionAtEnd() {
        #expect(tree.insertion(after: c) == .init(parentID: c, order: 0, reparentedChildID: nil))
    }

    @Test func insertionInMiddlePushesMainLineChildDown() {
        #expect(tree.insertion(after: a) == .init(parentID: a, order: 0, reparentedChildID: b))
    }
}
