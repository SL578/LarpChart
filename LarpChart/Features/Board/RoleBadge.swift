import SwiftUI

/// The small badge on a unit's top-right corner that shows its role.
/// Kept on its own so the web viewer can copy the style: an 18pt dark circle with a
/// white ring, holding a gold star (squad lead) or a white chevron (fireteam lead).
struct RoleBadge: View {
    static let diameter: CGFloat = 18

    let role: UnitRole

    var body: some View {
        if let symbol = role.badgeSymbol {
            Image(systemName: symbol)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(role.badgeTint)
                .frame(width: Self.diameter, height: Self.diameter)
                .background(Color(white: 0.12), in: Circle())
                .overlay { Circle().strokeBorder(.white, lineWidth: 1.5) }
                .accessibilityHidden(true)
        }
    }
}

extension UnitRole {
    var displayName: String {
        switch self {
        case .none: "None"
        case .squadLead: "Squad Lead"
        case .fireteamLead: "Fireteam Lead"
        }
    }

    /// nil for `.none`: no badge.
    var badgeSymbol: String? {
        switch self {
        case .none: nil
        case .squadLead: "star.fill"
        case .fireteamLead: "chevron.up"
        }
    }

    var badgeTint: Color {
        self == .squadLead ? .yellow : .white
    }
}
