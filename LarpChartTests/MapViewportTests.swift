import CoreGraphics
import Testing
@testable import LarpChart

struct MapViewportTests {
    /// A 2:1 map in a square container fits as 1000×500, letterboxed top and bottom.
    let imageSize = CGSize(width: 2000, height: 1000)
    let container = CGRect(x: 0, y: 0, width: 1000, height: 1000)

    func isClose(_ a: CGPoint, _ b: CGPoint) -> Bool {
        abs(a.x - b.x) < 1e-9 && abs(a.y - b.y) < 1e-9
    }

    @Test func defaultFrameIsAspectFit() {
        let frame = MapViewport().imageFrame(imageSize: imageSize, in: container)
        #expect(frame == MapGeometry.aspectFitRect(imageSize: imageSize, in: container))
    }

    @Test func pinchKeepsAnchorPointInPlace() {
        let anchor = CGPoint(x: 700, y: 400)
        let before = MapViewport().imageFrame(imageSize: imageSize, in: container)
        let mapPoint = MapGeometry.toNormalized(anchor, in: before)

        let zoomed = MapViewport().zoomed(by: 3, anchor: anchor, imageSize: imageSize, in: container)
        let after = zoomed.imageFrame(imageSize: imageSize, in: container)
        #expect(zoomed.scale == 3)
        #expect(isClose(MapGeometry.toView(mapPoint, in: after), anchor))
    }

    @Test func zoomStopsAtLimits() {
        let center = CGPoint(x: 500, y: 500)
        let tooFar = MapViewport().zoomed(by: 50, anchor: center, imageSize: imageSize, in: container)
        #expect(tooFar.scale == MapViewport.maxScale)
        let tooSmall = tooFar.zoomed(by: 0.001, anchor: center, imageSize: imageSize, in: container)
        #expect(tooSmall.scale == MapViewport.minScale)
        #expect(tooSmall.offset == .zero)
    }

    @Test func cannotPanAtFit() {
        let panned = MapViewport().panned(by: CGSize(width: 300, height: -200), imageSize: imageSize, in: container)
        #expect(panned == MapViewport())
    }

    @Test func panStopsAtMapEdges() {
        // At 4× the map is 4000×2000: up to 1500 pts of slack horizontally, 500 vertically.
        let zoomed = MapViewport(scale: 4)
        let panned = zoomed.panned(by: CGSize(width: 9999, height: -9999), imageSize: imageSize, in: container)
        #expect(panned.offset == CGSize(width: 1500, height: -500))
        let frame = panned.imageFrame(imageSize: imageSize, in: container)
        #expect(frame.minX == container.minX)
        #expect(frame.maxY == container.maxY)
    }

    @Test func narrowAxisStaysCentered() {
        // At 1.5× the map is 1500×750: wider than the container, still shorter.
        let panned = MapViewport(scale: 1.5).panned(by: CGSize(width: 100, height: 100), imageSize: imageSize, in: container)
        #expect(panned.offset == CGSize(width: 100, height: 0))
    }

    @Test func doubleTapZoomsInThenResets() {
        let tap = CGPoint(x: 300, y: 500)
        let zoomed = MapViewport().toggledZoom(anchor: tap, imageSize: imageSize, in: container)
        #expect(zoomed.scale == MapViewport.doubleTapScale)
        #expect(zoomed.toggledZoom(anchor: tap, imageSize: imageSize, in: container) == MapViewport())
    }

    @Test(arguments: [1.0, 2.5, 8.0])
    func normalizedRoundTripAtAnyZoom(scale: Double) {
        let viewport = MapViewport(scale: scale).panned(by: CGSize(width: -120, height: 80), imageSize: imageSize, in: container)
        let frame = viewport.imageFrame(imageSize: imageSize, in: container)
        let point = NormalizedPoint(x: 0.31, y: 0.77)
        let back = MapGeometry.toNormalized(MapGeometry.toView(point, in: frame), in: frame)
        #expect(abs(back.x - point.x) < 1e-9)
        #expect(abs(back.y - point.y) < 1e-9)
    }
}
