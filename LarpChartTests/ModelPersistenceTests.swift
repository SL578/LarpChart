import Foundation
import SwiftData
import Testing
@testable import LarpChart

@MainActor
struct ModelPersistenceTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try ModelContainer(
            for: Field.self, Plan.self, Phase.self, PlanUnit.self, Roster.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
    }

    /// A plan with one unit placed in a root phase that has an arrow and ink.
    func makePlan() -> (Plan, PlanUnit, Phase) {
        let field = Field(name: "Killhouse")
        let plan = Plan(name: "Push left", field: field)
        context.insert(field)
        context.insert(plan)
        let unit = PlanUnit(type: .breacher, label: "Alpha")
        plan.units.append(unit)
        let root = plan.addPhase()
        root.unitStates = [UnitState(unitID: unit.id, position: .init(x: 0.2, y: 0.3))]
        root.arrows = [Arrow(unitID: unit.id, path: [.init(x: 0.2, y: 0.3), .init(x: 0.6, y: 0.4)])]
        root.inkData = Data([1, 2, 3])
        return (plan, unit, root)
    }

    @Test func firstPhaseBecomesRoot() {
        let (plan, _, root) = makePlan()
        #expect(plan.rootPhaseID == root.id)
        #expect(root.parentPhaseID == nil)
        #expect(root.name == "Phase 1")
    }

    @Test func nextPhaseCopiesPositionsOnly() {
        let (plan, _, root) = makePlan()
        let next = plan.addPhase()
        #expect(next.parentPhaseID == root.id)
        #expect(next.order == 0)
        #expect(next.name == "Phase 2")
        #expect(next.unitStates == root.unitStates)
        #expect(next.arrows.isEmpty)
        #expect(next.inkData == nil)
    }

    @Test func copiedPositionsAreIndependent() {
        let (plan, _, root) = makePlan()
        let next = plan.addPhase()
        next.unitStates[0].position = .init(x: 0.9, y: 0.9)
        #expect(root.unitStates[0].position == .init(x: 0.2, y: 0.3))
    }

    @Test func addPhaseInMiddleReparentsFollowingPhase() {
        let (plan, _, root) = makePlan()
        let last = plan.addPhase(name: "Last")
        let middle = plan.addPhase(after: root, name: "Middle")
        #expect(middle.parentPhaseID == root.id)
        #expect(last.parentPhaseID == middle.id)
        #expect(plan.mainLinePhases.map(\.name) == ["Phase 1", "Middle", "Last"])
    }

    @Test func savedPlanReadsBack() throws {
        let (plan, unit, root) = makePlan()
        plan.addPhase()
        try context.save()

        let fresh = ModelContext(container)
        let plans = try fresh.fetch(FetchDescriptor<Plan>())
        let loaded = try #require(plans.first)
        #expect(loaded.field?.name == "Killhouse")
        #expect(loaded.units.map(\.type) == [.breacher])
        #expect(loaded.mainLinePhases.count == 2)
        let loadedRoot = try #require(loaded.phase(withID: root.id))
        #expect(loadedRoot.unitStates == [UnitState(unitID: unit.id, position: .init(x: 0.2, y: 0.3))])
        #expect(loadedRoot.arrows == root.arrows)
        #expect(loadedRoot.inkData == Data([1, 2, 3]))
    }

    @Test func rosterMembersReadBack() throws {
        let roster = Roster(name: "Squad", members: [
            RosterMember(name: "Kai", defaultUnitType: .sniper),
            RosterMember(name: "Rae", defaultUnitType: .medic),
        ])
        context.insert(roster)
        try context.save()

        let loaded = try #require(try ModelContext(container).fetch(FetchDescriptor<Roster>()).first)
        #expect(loaded.members == roster.members)
    }

    @Test func fieldImageNameAndLockReadBack() throws {
        let field = Field(name: "Field 1", imageData: Data([9, 8, 7]), thumbnailData: Data([1]))
        #expect(field.isMapLocked == false)
        context.insert(field)
        try context.save()
        field.name = "Killhouse"
        field.isMapLocked = true
        try context.save()

        let loaded = try #require(try ModelContext(container).fetch(FetchDescriptor<Field>()).first)
        #expect(loaded.name == "Killhouse")
        #expect(loaded.isMapLocked)
        #expect(loaded.imageData == Data([9, 8, 7]))
        #expect(loaded.thumbnailData == Data([1]))
    }

    @Test func deletingFieldCascades() throws {
        let (plan, _, _) = makePlan()
        try context.save()
        context.delete(try #require(plan.field))
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<Plan>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Phase>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<PlanUnit>()) == 0)
    }
}
