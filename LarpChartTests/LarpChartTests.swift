import Testing
@testable import LarpChart

struct LarpChartTests {
    @Test func appTargetLinks() {
        // Smoke test: the app module builds and loads into the test host.
        _ = RootView()
    }
}
