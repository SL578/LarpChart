import SwiftData
import SwiftUI

@main
struct LarpChartApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: [Field.self, Plan.self, Phase.self, PlanUnit.self, Roster.self])
    }
}
