import PhotosUI
import SwiftData
import SwiftUI

/// The home screen: a grid of saved fields. Importing a map creates a field and opens it.
struct FieldLibraryView: View {
    /// Opens a field's board.
    let open: (Field) -> Void

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Field.createdAt, order: .reverse) private var fields: [Field]

    @State private var showingPhotos = false
    @State private var photoItem: PhotosPickerItem?
    @State private var showingFiles = false
    @State private var isImporting = false
    @State private var importFailed = false

    @State private var renaming: Field?
    @State private var draftName = ""
    @State private var deleting: Field?

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 24)], spacing: 28) {
                ForEach(fields) { field in
                    Button { open(field) } label: { FieldCard(field: field) }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button("Rename", systemImage: "pencil") { startRename(field) }
                            Button("Delete", systemImage: "trash", role: .destructive) { deleting = field }
                        }
                }
            }
            .padding(24)
        }
        .overlay {
            if fields.isEmpty && !isImporting {
                ContentUnavailableView(
                    "No Fields",
                    systemImage: "map",
                    description: Text("Tap + to import a field map from Photos or Files.")
                )
            }
        }
        .navigationTitle("Fields")
        .toolbar {
            ToolbarItem(placement: .primaryAction) { addMenu }
            ToolbarItem(placement: .topBarLeading) { SettingsButton() }
        }
        .photosPicker(isPresented: $showingPhotos, selection: $photoItem, matching: .images)
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            photoItem = nil
            importMap(named: nil) { try await item.loadTransferable(type: Data.self) }
        }
        .fileImporter(isPresented: $showingFiles, allowedContentTypes: [.image]) { result in
            guard case .success(let url) = result else { return }
            importMap(named: url) { try readSecurityScoped(url) }
        }
        .alert("Couldn't Import Map", isPresented: $importFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("That file isn't an image LarpChart can read.")
        }
        .alert("Rename Field", isPresented: isPresent($renaming)) {
            TextField("Name", text: $draftName)
            Button("Save") { commitRename() }
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog(
            "Delete \(deleting?.name ?? "field")?",
            isPresented: isPresent($deleting),
            titleVisibility: .visible
        ) {
            Button("Delete Field and Its Plans", role: .destructive) { commitDelete() }
        } message: {
            Text("This can't be undone.")
        }
    }

    private var addMenu: some View {
        Menu {
            Button("Photos", systemImage: "photo.on.rectangle") { showingPhotos = true }
            Button("Files", systemImage: "folder") { showingFiles = true }
        } label: {
            if isImporting {
                ProgressView()
            } else {
                Label("Add Field", systemImage: "plus")
            }
        }
        .disabled(isImporting)
    }

    // MARK: - Import

    private func importMap(named fileURL: URL?, load: @escaping () async throws -> Data?) {
        isImporting = true
        Task {
            defer { isImporting = false }
            do {
                guard let data = try await load() else { throw MapImageImporter.ImportError.unreadableImage }
                let prepared = try await Task.detached(priority: .userInitiated) {
                    try MapImageImporter.prepare(data)
                }.value
                let field = Field(
                    name: MapImageImporter.defaultName(fileURL: fileURL, existingNames: fields.map(\.name)),
                    imageData: prepared.imageData,
                    thumbnailData: prepared.thumbnailData
                )
                modelContext.insert(field)
                open(field)
            } catch {
                importFailed = true
            }
        }
    }

    private func readSecurityScoped(_ url: URL) throws -> Data {
        let accessing = url.startAccessingSecurityScopedResource()
        defer { if accessing { url.stopAccessingSecurityScopedResource() } }
        return try Data(contentsOf: url)
    }

    // MARK: - Rename and delete

    private func startRename(_ field: Field) {
        draftName = field.name
        renaming = field
    }

    private func commitRename() {
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        if let renaming, !name.isEmpty {
            renaming.name = name
        }
        renaming = nil
    }

    private func commitDelete() {
        guard let deleting else { return }
        modelContext.delete(deleting)
        self.deleting = nil
    }

    /// A Bool binding that is true while `item` is set, and clears it when dismissed.
    private func isPresent<T>(_ item: Binding<T?>) -> Binding<Bool> {
        Binding(get: { item.wrappedValue != nil }, set: { if !$0 { item.wrappedValue = nil } })
    }
}
