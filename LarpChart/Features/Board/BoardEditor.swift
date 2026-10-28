import SwiftUI

/// Editing one phase of a plan: the map, its units, the palette, and the action bar.
struct BoardEditor: View {
    @Bindable var field: Field
    let plan: Plan
    let phase: Phase
    let image: UIImage

    @AppStorage("leftHandMode") private var isLeftHanded = false
    @State private var isPaletteCollapsed = false
    /// Tap-to-place: while set, each tap on the map places one unit of this type.
    @State private var armedType: UnitType?
    @State private var selectedUnitID: UUID?
    @State private var imageFrame: CGRect = .zero
    @State private var paletteFrame: CGRect = .zero
    /// A tile being dragged out of the palette, and where the finger is.
    @State private var paletteDrag: (type: UnitType, location: CGPoint)?

    @State private var renaming: PlanUnit?
    @State private var draftLabel = ""

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: isLeftHanded ? .topTrailing : .topLeading) {
                ZoomableMapView(
                    image: image,
                    isLocked: field.isMapLocked,
                    doubleTapZooms: armedType == nil,
                    onTap: handleMapTap,
                    zoomBlocked: { unitID(at: $0) != nil },
                    onImageFrameChange: { imageFrame = $0 }
                ) { frame in
                    UnitsLayer(plan: plan, phase: phase, imageFrame: frame, selectedUnitID: $selectedUnitID)
                }

                actionBar(in: proxy.size)

                palette
                    .padding(16)
                    .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(BoardSpace.name)) } action: {
                        paletteFrame = $0
                    }

                if let paletteDrag {
                    UnitMarker(type: paletteDrag.type)
                        .scaleEffect(1.15)
                        .position(paletteDrag.location)
                        .allowsHitTesting(false)
                }
            }
            .coordinateSpace(.named(BoardSpace.name))
            .animation(.snappy(duration: 0.25), value: isLeftHanded)
        }
        .alert("Rename Unit", isPresented: isRenaming) {
            TextField("Label", text: $draftLabel)
            Button("Save") { commitRename() }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var palette: some View {
        UnitPalette(
            armedType: $armedType,
            isCollapsed: $isPaletteCollapsed,
            isLeftHanded: isLeftHanded,
            onDragChanged: { type, location in paletteDrag = (type, location) },
            onDragEnded: handleDrop
        )
    }

    @ViewBuilder
    private func actionBar(in container: CGSize) -> some View {
        if let id = selectedUnitID, let unit = plan.unit(withID: id), let position = phase.position(of: id) {
            UnitActionBar(
                unitPoint: MapGeometry.toView(position, in: imageFrame),
                container: container,
                role: Bindable(unit).role,
                onRename: { startRename(unit) },
                onDelete: { delete(unit) }
            )
        }
    }

    // MARK: - Placing

    /// A tap on a unit selects it, whatever tile is selected. Elsewhere it places
    /// the selected tile's type, or clears the selection.
    private func handleMapTap(_ location: CGPoint) {
        if let id = unitID(at: location) {
            selectedUnitID = id
        } else if let armedType, imageFrame.contains(location) {
            place(armedType, at: location)
        } else {
            selectedUnitID = nil
        }
    }

    private func unitID(at location: CGPoint) -> UUID? {
        MapGeometry.unit(at: location, among: phase.unitStates, in: imageFrame, radius: UnitMarker.hitRadius)
    }

    /// Drops outside the map, or back onto the palette, cancel.
    private func handleDrop(_ type: UnitType, at location: CGPoint) {
        paletteDrag = nil
        guard imageFrame.contains(location), !paletteFrame.contains(location) else { return }
        place(type, at: location)
    }

    private func place(_ type: UnitType, at location: CGPoint) {
        selectedUnitID = nil
        plan.addUnit(type, at: MapGeometry.toNormalized(location, in: imageFrame), in: phase)
    }

    // MARK: - Rename and delete

    private var isRenaming: Binding<Bool> {
        Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })
    }

    private func startRename(_ unit: PlanUnit) {
        draftLabel = unit.label
        renaming = unit
    }

    private func commitRename() {
        renaming?.label = draftLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        renaming = nil
    }

    private func delete(_ unit: PlanUnit) {
        selectedUnitID = nil
        plan.deleteUnit(unit)
    }
}
