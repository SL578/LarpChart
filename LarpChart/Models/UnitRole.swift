import Foundation

/// What a unit does in the squad, on top of what it is (its `UnitType`).
/// A squad lead can be a rifleman or a medic. Stored by raw value, so cases can be
/// added but not renamed.
enum UnitRole: String, Codable, CaseIterable, Identifiable {
    case none
    case squadLead
    case fireteamLead

    var id: String { rawValue }
}
