import SwiftUI

/// The floating icon palette. Drag a tile onto the map to place one unit, or tap a
/// tile to arm it and then tap the map to place that type repeatedly.
struct UnitPalette: View {
    @Binding var armedType: UnitType?
    @Binding var isCollapsed: Bool
    /// Which screen edge the palette sits on; the collapse chevron points toward it.
    let isLeftHanded: Bool
    /// Drag locations are in the `BoardSpace` coordinate space.
    let onDragChanged: (UnitType, CGPoint) -> Void
    let onDragEnded: (UnitType, CGPoint) -> Void

    private static let tileSize: CGFloat = 52

    var body: some View {
        Group {
            if isCollapsed {
                Button { isCollapsed = false } label: {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.title2)
                        .frame(width: Self.tileSize, height: Self.tileSize)
                }
                .accessibilityLabel("Show Unit Palette")
            } else {
                expanded
            }
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .animation(.snappy(duration: 0.2), value: isCollapsed)
    }

    private var expanded: some View {
        VStack(alignment: isLeftHanded ? .trailing : .leading, spacing: 4) {
            collapseButton
            ForEach(UnitType.Category.allCases, id: \.self) { category in
                Text(category.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
                Grid(horizontalSpacing: 4, verticalSpacing: 4) {
                    ForEach(rows(of: category.types), id: \.first) { row in
                        GridRow {
                            ForEach(row) { type in tile(type) }
                        }
                    }
                }
            }
        }
        .padding(8)
        // Hug the tiles instead of stretching across the board.
        .fixedSize()
    }

    private var collapseButton: some View {
        Button { isCollapsed = true } label: {
            Image(systemName: isLeftHanded ? "chevron.right" : "chevron.left")
                .font(.body.weight(.semibold))
                .frame(width: 44, height: 36)
        }
        .accessibilityLabel("Hide Unit Palette")
    }

    /// Two tiles per row.
    private func rows(of types: [UnitType]) -> [[UnitType]] {
        stride(from: 0, to: types.count, by: 2).map { Array(types[$0..<min($0 + 2, types.count)]) }
    }

    private func tile(_ type: UnitType) -> some View {
        let isArmed = armedType == type
        return UnitMarker(type: type)
            .frame(width: Self.tileSize, height: Self.tileSize)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isArmed ? Color.accentColor.opacity(0.35) : .clear)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor, lineWidth: isArmed ? 2.5 : 0)
            }
            .contentShape(Rectangle())
            .onTapGesture { armedType = isArmed ? nil : type }
            .gesture(
                DragGesture(minimumDistance: 8, coordinateSpace: .named(BoardSpace.name))
                    .onChanged { onDragChanged(type, $0.location) }
                    .onEnded { onDragEnded(type, $0.location) }
            )
            .accessibilityElement()
            .accessibilityLabel(type.displayName)
            .accessibilityHint("Drag onto the map, or tap to place repeatedly.")
            .accessibilityAddTraits(isArmed ? [.isButton, .isSelected] : .isButton)
    }
}
