import CoreGraphics
import Testing
@testable import LarpChart

struct MapGeometryTests {
    let frame = CGRect(x: 100, y: 50, width: 400, height: 200)

    @Test func cornersAndCenterMapToView() {
        #expect(MapGeometry.toView(.init(x: 0, y: 0), in: frame) == CGPoint(x: 100, y: 50))
        #expect(MapGeometry.toView(.init(x: 1, y: 1), in: frame) == CGPoint(x: 500, y: 250))
        #expect(MapGeometry.toView(.init(x: 0.5, y: 0.5), in: frame) == CGPoint(x: 300, y: 150))
    }

    @Test func viewMapsToNormalized() {
        #expect(MapGeometry.toNormalized(CGPoint(x: 300, y: 150), in: frame) == .init(x: 0.5, y: 0.5))
        #expect(MapGeometry.toNormalized(CGPoint(x: 100, y: 250), in: frame) == .init(x: 0, y: 1))
    }

    @Test(arguments: [(0.0, 0.0), (0.25, 0.75), (1.0, 1.0), (0.123, 0.987)])
    func roundTrip(x: Double, y: Double) {
        let original = NormalizedPoint(x: x, y: y)
        let back = MapGeometry.toNormalized(MapGeometry.toView(original, in: frame), in: frame)
        #expect(abs(back.x - x) < 1e-9)
        #expect(abs(back.y - y) < 1e-9)
    }

    @Test func pointsOutsideImageAreNotClampedUntilAsked() {
        let outside = MapGeometry.toNormalized(CGPoint(x: 0, y: 300), in: frame)
        #expect(outside == .init(x: -0.25, y: 1.25))
        #expect(outside.clamped() == .init(x: 0, y: 1))
    }

    @Test func zeroSizeFrameDoesNotDivideByZero() {
        #expect(MapGeometry.toNormalized(CGPoint(x: 10, y: 10), in: .zero) == .init(x: 0, y: 0))
    }

    @Test func aspectFitWideImage() {
        let container = CGRect(x: 0, y: 0, width: 1000, height: 1000)
        let rect = MapGeometry.aspectFitRect(imageSize: CGSize(width: 2000, height: 1000), in: container)
        #expect(rect == CGRect(x: 0, y: 250, width: 1000, height: 500))
    }

    @Test func aspectFitTallImage() {
        let container = CGRect(x: 0, y: 0, width: 1000, height: 800)
        let rect = MapGeometry.aspectFitRect(imageSize: CGSize(width: 100, height: 200), in: container)
        #expect(rect == CGRect(x: 300, y: 0, width: 400, height: 800))
    }

    @Test func aspectFitEmptyImage() {
        let container = CGRect(x: 0, y: 0, width: 100, height: 100)
        let rect = MapGeometry.aspectFitRect(imageSize: .zero, in: container)
        #expect(rect == CGRect(x: 50, y: 50, width: 0, height: 0))
    }
}
