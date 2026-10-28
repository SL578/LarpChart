import SwiftData
import SwiftUI

@main
struct LarpChartApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        // Models are registered here starting in M1.
        .modelContainer(for: [])
    }
}
