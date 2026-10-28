import SwiftData
import SwiftUI

/// The board for one field: loads its map and plan, plus the lock toggle.
struct BoardView: View {
    @Bindable var field: Field

    @Environment(\.modelContext) private var modelContext
    @State private var image: UIImage?
    @State private var plan: Plan?
    @State private var loadFailed = false

    var body: some View {
        content
            .navigationTitle(field.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) { lockButton }
                ToolbarItem(placement: .topBarLeading) { SettingsButton() }
            }
            .task(id: field.id) {
                plan = field.defaultPlan(in: modelContext)
                await loadImage()
            }
    }

    @ViewBuilder
    private var content: some View {
        if let image, let plan, let phase = plan.rootPhase {
            BoardEditor(field: field, plan: plan, phase: phase, image: image)
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
