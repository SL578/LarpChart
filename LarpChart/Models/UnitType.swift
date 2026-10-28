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

    /// Prefix for auto labels (R1, R2…). Changing one only affects new units.
    var shortCode: String {
        switch self {
        case .rifleman: "R"
        case .breacher: "B"
        case .sniper: "S"
        case .medic: "M"
        case .logistics: "L"
        case .gunTruck: "GT"
        case .helicopter: "H"
        case .flag: "F"
        case .bombSite: "BS"
        case .spawn: "SP"
        case .cover: "C"
        case .door: "D"
        case .enemyContact: "E"
        }
    }
}
