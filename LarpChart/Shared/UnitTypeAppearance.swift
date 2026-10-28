import SwiftUI

/// Placeholder icons and colors for each unit type (custom icons are on the roadmap).
extension UnitType {
    var displayName: String {
        switch self {
        case .rifleman: "Rifleman"
        case .breacher: "Breacher"
        case .sniper: "Sniper"
        case .medic: "Medic"
        case .logistics: "Logistics"
        case .gunTruck: "Gun Truck"
        case .helicopter: "Helicopter"
        case .flag: "Flag"
        case .bombSite: "Bomb Site"
        case .spawn: "Spawn"
        case .cover: "Cover"
        case .door: "Door"
        case .enemyContact: "Enemy Contact"
        }
    }

    var symbolName: String {
        switch self {
        case .rifleman: "person.fill"
        case .breacher: "hammer.fill"
        case .sniper: "scope"
        case .medic: "cross.case.fill"
        case .logistics: "shippingbox.fill"
        case .gunTruck: "truck.box.fill"
        case .helicopter: "airplane"
        case .flag: "flag.fill"
        case .bombSite: "burst.fill"
        case .spawn: "house.fill"
        case .cover: "shield.fill"
        case .door: "door.left.hand.open"
        case .enemyContact: "exclamationmark.triangle.fill"
        }
    }

    var tint: Color {
        if self == .enemyContact { return .red }
        switch category {
        case .infantry: return .blue
        case .mechanized: return .green
        case .objective: return .orange
        }
    }
}

extension UnitType.Category {
    var title: String {
        switch self {
        case .infantry: "Infantry"
        case .mechanized: "Mechanized"
        case .objective: "Objectives"
        }
    }

    var types: [UnitType] {
        UnitType.allCases.filter { $0.category == self }
    }
}
