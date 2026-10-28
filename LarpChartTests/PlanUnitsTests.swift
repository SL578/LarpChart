import Foundation
import SwiftData
import Testing
@testable import LarpChart

@MainActor
struct PlanUnitsTests {
    let container: ModelContainer
    let context: ModelContext
    let field: Field

    init() throws {
        container = try ModelContainer(
            for: Field.self, Plan.self, Phase.self, PlanUnit.self, Roster.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
        field = Field(name: "Killhouse")
        context.insert(field)
    }

    // MARK: - Default plan

    @Test func defaultPlanIsCreatedWithRootPhase() throws {
        let plan = field.defaultPlan(in: context)
        try context.save()
        #expect(field.plans.count == 1)
        #expect(plan.name == "Plan 1")
        #expect(plan.rootPhase != nil)
        #expect(plan.phases.count == 1)
    }

    @Test func defaultPlanIsReused() {
        let first = field.defaultPlan(in: context)
        let second = field.defaultPlan(in: context)
        #expect(first.id == second.id)
        #expect(field.plans.count == 1)
        #expect(second.phases.count == 1)
    }

    @Test func defaultPlanGetsRootPhaseIfMissing() {
        let plan = Plan(name: "Empty", field: field)
        context.insert(plan)
        #expect(field.defaultPlan(in: context).id == plan.id)
        #expect(plan.rootPhase != nil)
    }

    // MARK: - Add, move, delete

    @Test func addUnitPlacesItInPhase() throws {
        let plan = field.defaultPlan(in: context)
        let phase = try #require(plan.rootPhase)
        let unit = plan.addUnit(.sniper, at: .init(x: 0.25, y: 0.75), in: phase)
        #expect(plan.units.map(\.id) == [unit.id])
        #expect(unit.type == .sniper)
        #expect(phase.position(of: unit.id) == .init(x: 0.25, y: 0.75))
    }

    @Test func addUnitClampsToMap() throws {
        let plan = field.defaultPlan(in: context)
        let phase = try #require(plan.rootPhase)
        let unit = plan.addUnit(.flag, at: .init(x: -0.2, y: 1.4), in: phase)
        #expect(phase.position(of: unit.id) == .init(x: 0, y: 1))
    }

    @Test func moveUnitChangesOnlyThatUnit() throws {
        let plan = field.defaultPlan(in: context)
        let phase = try #require(plan.rootPhase)
        let a = plan.addUnit(.rifleman, at: .init(x: 0.1, y: 0.1), in: phase)
        let b = plan.addUnit(.rifleman, at: .init(x: 0.2, y: 0.2), in: phase)
        phase.moveUnit(a.id, to: .init(x: 0.5, y: 1.5))
        #expect(phase.position(of: a.id) == .init(x: 0.5, y: 1))
        #expect(phase.position(of: b.id) == .init(x: 0.2, y: 0.2))
    }

    @Test func moveUnitOnlyAffectsItsPhase() throws {
        let plan = field.defaultPlan(in: context)
        let root = try #require(plan.rootPhase)
        let unit = plan.addUnit(.medic, at: .init(x: 0.3, y: 0.3), in: root)
        let next = plan.addPhase()
        next.moveUnit(unit.id, to: .init(x: 0.9, y: 0.9))
        #expect(root.position(of: unit.id) == .init(x: 0.3, y: 0.3))
        #expect(next.position(of: unit.id) == .init(x: 0.9, y: 0.9))
    }

    @Test func moveUnknownUnitDoesNothing() throws {
        let plan = field.defaultPlan(in: context)
        let phase = try #require(plan.rootPhase)
        plan.addUnit(.door, at: .init(x: 0.4, y: 0.4), in: phase)
        let before = phase.unitStates
        phase.moveUnit(UUID(), to: .init(x: 0.9, y: 0.9))
        #expect(phase.unitStates == before)
    }

    @Test func deleteUnitRemovesStatesAndArrowsEverywhere() throws {
        let plan = field.defaultPlan(in: context)
        let root = try #require(plan.rootPhase)
        let gone = plan.addUnit(.breacher, at: .init(x: 0.1, y: 0.1), in: root)
        let kept = plan.addUnit(.rifleman, at: .init(x: 0.2, y: 0.2), in: root)
        let next = plan.addPhase()
        let freeArrow = Arrow(path: [.init(x: 0, y: 0), .init(x: 1, y: 1)])
        root.arrows = [
            Arrow(unitID: gone.id, path: [.init(x: 0.1, y: 0.1), .init(x: 0.5, y: 0.5)]),
            Arrow(unitID: kept.id, path: [.init(x: 0.2, y: 0.2), .init(x: 0.6, y: 0.6)]),
            freeArrow,
        ]
        next.arrows = [Arrow(unitID: gone.id, path: [.init(x: 0.1, y: 0.1), .init(x: 0.2, y: 0.9)])]

        plan.deleteUnit(gone)
        try context.save()

        #expect(plan.units.map(\.id) == [kept.id])
        #expect(root.unitStates.map(\.unitID) == [kept.id])
        #expect(next.unitStates.map(\.unitID) == [kept.id])
        #expect(root.arrows.map(\.unitID) == [kept.id, nil])
        #expect(next.arrows.isEmpty)
        #expect(try context.fetch(FetchDescriptor<PlanUnit>()).map(\.id) == [kept.id])
    }

    // MARK: - Auto labels

    @Test func autoLabelsCountPerType() throws {
        let plan = field.defaultPlan(in: context)
        let phase = try #require(plan.rootPhase)
        let labels = [UnitType.rifleman, .rifleman, .breacher, .rifleman, .gunTruck]
            .map { plan.addUnit($0, at: .init(x: 0.5, y: 0.5), in: phase).label }
        #expect(labels == ["R1", "R2", "B1", "R3", "GT1"])
    }

    @Test func autoLabelsReuseFreedNumbers() {
        #expect(UnitLabels.next(for: .rifleman, existing: ["R1", "R3"]) == "R2")
        #expect(UnitLabels.next(for: .rifleman, existing: []) == "R1")
    }

    @Test func autoLabelsIgnoreOtherPrefixes() {
        // "BS1" (bomb site) must not block "B1" (breacher), and renamed units free their number.
        #expect(UnitLabels.next(for: .breacher, existing: ["BS1", "Alpha"]) == "B1")
        #expect(UnitLabels.next(for: .bombSite, existing: ["B1"]) == "BS1")
    }

    @Test func shortCodesAreUnique() {
        let codes = UnitType.allCases.map(\.shortCode)
        #expect(Set(codes).count == codes.count)
    }
}
