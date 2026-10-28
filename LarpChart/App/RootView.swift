import SwiftUI

/// Root navigation: field library in the sidebar, board in the detail column.
struct RootView: View {
    var body: some View {
        NavigationSplitView {
            List {}
                .navigationTitle("Fields")
        } detail: {
            ContentUnavailableView(
                "No Field Selected",
                systemImage: "map",
                description: Text("Pick a field from the sidebar.")
            )
        }
    }
}

#Preview {
    RootView()
}
