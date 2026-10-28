import SwiftUI

/// The field map with pinch-zoom, pan, and double-tap zoom. All map gestures are off
/// while `isLocked`; gestures on views layered inside stay active, and so does `onTap`.
///
/// `overlay` is drawn above the map and gets the current image frame, so whatever it
/// places with `MapGeometry` follows every pan and zoom. Its gestures win over the map's.
struct ZoomableMapView<Overlay: View>: View {
    let image: UIImage
    let isLocked: Bool
    /// Off while placing units, so two quick taps place two units instead of zooming.
    var doubleTapZooms = true
    /// A single tap on the map (not on an overlay view), in the view's coordinates.
    var onTap: (CGPoint) -> Void = { _ in }
    /// Return true to skip double-tap zoom at that point.
    var zoomBlocked: (CGPoint) -> Bool = { _ in false }
    /// Reports the image frame whenever pan, zoom, or the view size changes it.
    var onImageFrameChange: (CGRect) -> Void = { _ in }
    @ViewBuilder var overlay: (CGRect) -> Overlay

    @State private var viewport = MapViewport()
    /// The viewport when the current pinch/drag began; each change is applied to it.
    @State private var gestureStart: MapViewport?

    var body: some View {
        GeometryReader { proxy in
            let container = CGRect(origin: .zero, size: proxy.size)
            let frame = viewport.imageFrame(imageSize: image.size, in: container)
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)
                overlay(frame)
            }
            .contentShape(Rectangle())
            .gesture(panAndZoom(in: container), including: isLocked ? .subviews : .all)
            .gesture(taps(in: container))
            .onChange(of: proxy.size) {
                viewport = viewport.clamped(imageSize: image.size, in: container)
            }
            .onChange(of: frame, initial: true) { _, newFrame in
                onImageFrameChange(newFrame)
            }
        }
        .clipped()
        .background(Color(.secondarySystemBackground))
    }

    private func panAndZoom(in container: CGRect) -> some Gesture {
        SimultaneousGesture(MagnifyGesture(), DragGesture())
            .onChanged { value in
                let start = gestureStart ?? viewport
                gestureStart = start
                var next = start
                if let magnify = value.first {
                    next = next.zoomed(
                        by: magnify.magnification, anchor: magnify.startLocation,
                        imageSize: image.size, in: container
                    )
                }
                if let drag = value.second {
                    next = next.panned(by: drag.translation, imageSize: image.size, in: container)
                }
                viewport = next
            }
            .onEnded { _ in gestureStart = nil }
    }

    /// Every tap goes to `onTap` right away (no waiting to rule out a double-tap).
    /// A double-tap also zooms, unless locked, turned off, or `zoomBlocked` says no
    /// (for example, when the tap lands on a unit).
    private func taps(in container: CGRect) -> AnyGesture<Void> {
        let singleTap = SpatialTapGesture().onEnded { value in onTap(value.location) }
        guard doubleTapZooms && !isLocked else {
            return AnyGesture(singleTap.map { _ in () })
        }
        let doubleTap = SpatialTapGesture(count: 2).onEnded { value in
            guard !zoomBlocked(value.location) else { return }
            withAnimation(.snappy) {
                viewport = viewport.toggledZoom(anchor: value.location, imageSize: image.size, in: container)
            }
        }
        return AnyGesture(SimultaneousGesture(singleTap, doubleTap).map { _ in () })
    }
}
