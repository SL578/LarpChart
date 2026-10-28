import Foundation
import SwiftData
import Testing
@testable import LarpChart

@MainActor
struct UnitRoleTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try ModelContainer(
            for: Field.self, Plan.self, Phase.self, PlanUnit.self, Roster.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
    }

    /// A plan on a field, with its root phase.
    func makePlan() throws -> (Plan, Phase) {
        let field = Field(name: "Killhouse")
        context.insert(field)
        let plan = field.defaultPlan(in: context)
        return (plan, try #require(plan.rootPhase))
    }

    @Test func roleDefaultsToNone() throws {
        let (plan, phase) = try makePlan()
        let unit = plan.addUnit(.medic, at: .init(x: 0.5, y: 0.5), in: phase)
        #expect(unit.role == .none)
        #expect(PlanUnit(type: .sniper).role == .none)
    }

    @Test(arguments: [UnitRole.squadLead, .fireteamLead, .none])
    func rolePersists(role: UnitRole) throws {
        let (plan, phase) = try makePlan()
        let unit = plan.addUnit(.rifleman, at: .init(x: 0.5, y: 0.5), in: phase)
        unit.role = .fireteamLead
        unit.role = role
        try context.save()

        let fresh = ModelContext(container)
        let id = unit.id
        let fetched = try fresh.fetch(FetchDescriptor<PlanUnit>(predicate: #Predicate { $0.id == id }))
        #expect(fetched.first?.role == role)
    }

    @Test func unknownRoleReadsAsNone() {
        let unit = PlanUnit(type: .breacher)
        unit.roleRaw = "platoonSergeant"
        #expect(unit.role == .none)
    }

    @Test func roleIsTheSameInEveryPhase() throws {
        let (plan, phase) = try makePlan()
        let unit = plan.addUnit(.gunTruck, at: .init(x: 0.5, y: 0.5), in: phase)
        unit.role = .squadLead
        let next = plan.addPhase()
        next.moveUnit(unit.id, to: .init(x: 0.9, y: 0.1))
        #expect(plan.unit(withID: unit.id)?.role == .squadLead)
        #expect(next.unitStates.map(\.unitID) == [unit.id])
    }
}
