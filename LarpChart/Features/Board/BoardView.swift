import SwiftUI

/// The board for one field: its map, plus the lock toggle.
struct BoardView: View {
    @Bindable var field: Field

    @State private var image: UIImage?
    @State private var loadFailed = false

    var body: some View {
        content
            .navigationTitle(field.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) { lockButton }
            }
            .task(id: field.id) { await loadImage() }
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            ZoomableMapView(image: image, isLocked: field.isMapLocked)
        } else if loadFailed {
            ContentUnavailableView(
                "Map Unavailable",
                systemImage: "exclamationmark.triangle",
                description: Text("This field's map image couldn't be loaded.")
            )
        } else {
            ProgressView()
        }
    }

    private var lockButton: some View {
        Button {
            field.isMapLocked.toggle()
        } label: {
            Label(
                field.isMapLocked ? "Map Locked" : "Lock Map",
                systemImage: field.isMapLocked ? "lock.fill" : "lock.open"
            )
            .labelStyle(.titleAndIcon)
        }
        .tint(field.isMapLocked ? .orange : nil)
    }

    /// Decodes the map once, off the main thread.
    private func loadImage() async {
        let data = field.imageData
        let decoded = await Task.detached(priority: .userInitiated) {
            data.flatMap(UIImage.init(data:))?.preparingForDisplay()
        }.value
        image = decoded
        loadFailed = decoded == nil
    }
}
