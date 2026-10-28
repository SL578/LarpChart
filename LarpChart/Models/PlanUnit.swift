import Foundation
import SwiftData

/// A unit's identity within a plan. Its position lives per phase in `UnitState`.
@Model
final class PlanUnit {
    @Attribute(.unique) var id: UUID
    var typeRaw: String
    var label: String
    /// Same in every phase. Defaulted so stores from before roles migrate as `.none`.
    var roleRaw: String = UnitRole.none.rawValue
    var rosterMemberID: UUID?
    var plan: Plan?

    var type: UnitType {
        get { UnitType(rawValue: typeRaw) ?? .rifleman }
        set { typeRaw = newValue.rawValue }
    }

    var role: UnitRole {
        get { UnitRole(rawValue: roleRaw) ?? .none }
        set { roleRaw = newValue.rawValue }
    }

    init(type: UnitType, label: String = "", rosterMemberID: UUID? = nil) {
        self.id = UUID()
        self.typeRaw = type.rawValue
        self.label = label
        self.rosterMemberID = rosterMemberID
    }
}
