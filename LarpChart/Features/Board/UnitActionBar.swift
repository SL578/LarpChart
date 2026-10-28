import SwiftUI

/// Role, Rename, and Delete for the selected unit: everything you can do to one unit. Floats just above the unit,
/// or below it when the unit is near the top edge.
struct UnitActionBar: View {
    let unitPoint: CGPoint
    let container: CGSize
    @Binding var role: UnitRole
    let onRename: () -> Void
    let onDelete: () -> Void

    private static let buttonSize = CGSize(width: 44, height: 36)
    private static let size = CGSize(width: buttonSize.width * 3 + 2, height: buttonSize.height)
    /// Distance from the unit's center to the bar's near edge; clears the label below too.
    private static let gap: CGFloat = 30

    var body: some View {
        HStack(spacing: 0) {
            Menu {
                Picker("Role", selection: $role) {
                    ForEach(UnitRole.allCases) { role in
                        Text(role.displayName).tag(role)
                    }
                }
            } label: {
                Image(systemName: role == .none ? "star" : "star.fill")
                    .frame(width: Self.buttonSize.width, height: Self.buttonSize.height)
            }
            .accessibilityLabel("Role")
            .accessibilityValue(role.displayName)
            Divider().frame(height: 20)
            Button(action: onRename) {
                Image(systemName: "pencil")
                    .frame(width: Self.buttonSize.width, height: Self.buttonSize.height)
            }
            .accessibilityLabel("Rename Unit")
            Divider().frame(height: 20)
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .frame(width: Self.buttonSize.width, height: Self.buttonSize.height)
            }
            .accessibilityLabel("Delete Unit")
        }
        .font(.callout.weight(.semibold))
        .contentShape(Capsule())
        .background(.thinMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.3), radius: 4, y: 1)
        .position(position)
    }

    private var position: CGPoint {
        let halfWidth = Self.size.width / 2
        let halfHeight = Self.size.height / 2
        let x = min(max(unitPoint.x, halfWidth + 8), container.width - halfWidth - 8)
        let above = unitPoint.y - Self.gap - halfHeight
        let y = above - halfHeight < 8 ? unitPoint.y + Self.gap + 12 + halfHeight : above
        return CGPoint(x: x, y: y)
    }
}
