import Foundation
import SwiftData

extension Field {
    /// The plan the board edits: the field's oldest plan, created with a root phase
    /// on first open. A plan picker comes later; until then each field has one plan.
    func defaultPlan(in context: ModelContext) -> Plan {
        let plan: Plan
        if let existing = plans.min(by: { $0.createdAt < $1.createdAt }) {
            plan = existing
        } else {
            plan = Plan(name: "Plan 1", field: self)
            context.insert(plan)
        }
        if plan.rootPhase == nil {
            plan.addPhase()
        }
        return plan
    }
}
