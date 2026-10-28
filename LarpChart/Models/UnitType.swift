import Foundation

/// Every icon a unit can be. Stored by raw value, so cases can be added but not renamed.
enum UnitType: String, Codable, CaseIterable, Identifiable {
    // Infantry
    case rifleman
    case breacher
    case sniper
    case medic
    // Mechanized
    case logistics
    case gunTruck
    case helicopter
    // Objectives & terrain
    case flag
    case bombSite
    case spawn
    case cover
    case door
    case enemyContact

    enum Category: String, CaseIterable {
        case infantry
        case mechanized
        case objective
    }

    var id: String { rawValue }

    var category: Category {
        switch self {
        case .rifleman, .breacher, .sniper, .medic:
            .infantry
        case .logistics, .gunTruck, .helicopter:
            .mechanized
        case .flag, .bombSite, .spawn, .cover, .door, .enemyContact:
            .objective
        }
    }
}
