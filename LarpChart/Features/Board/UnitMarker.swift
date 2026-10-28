import SwiftUI

/// A unit's icon. Always the same on-screen size, whatever the zoom, so it stays easy to hit.
struct UnitMarker: View {
    static let diameter: CGFloat = 44
    /// Extra touch area around the circle.
    static let hitSlop: CGFloat = 6
    static var hitRadius: CGFloat { diameter / 2 + hitSlop }

    let type: UnitType
    var label: String = ""
    var role: UnitRole = .none
    var isSelected = false

    var body: some View {
        Image(systemName: type.symbolName)
            .font(.system(size: 19, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: Self.diameter, height: Self.diameter)
            .background(type.tint, in: Circle())
            .overlay {
                Circle().strokeBorder(.white, lineWidth: isSelected ? 3 : 1.5)
            }
            .shadow(color: .black.opacity(0.5), radius: 3, y: 1)
            // Pushed out past the corner so it overlaps only the ring, never the icon.
            .overlay(alignment: .topTrailing) {
                RoleBadge(role: role)
                    .offset(x: 5, y: -5)
            }
            .overlay(alignment: .bottom) {
                if !label.isEmpty {
                    Text(label)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.horizontal, 5)
                        .background(.black.opacity(0.65), in: Capsule())
                        .offset(y: 18)
                }
            }
            .scaleEffect(isSelected ? 1.12 : 1)
            .animation(.snappy(duration: 0.15), value: isSelected)
    }
}

/// The coordinate space the board's map, units, and palette share.
enum BoardSpace {
    static let name = "board"
}
