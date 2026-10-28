import SwiftUI

/// Root navigation: the field library is home; a field's board opens full-screen on top.
struct RootView: View {
    @State private var path: [Field] = []

    var body: some View {
        NavigationStack(path: $path) {
            FieldLibraryView { field in path.append(field) }
                .navigationDestination(for: Field.self) { field in
                    BoardView(field: field)
                        .id(field.id)
                }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: Field.self, inMemory: true)
}
