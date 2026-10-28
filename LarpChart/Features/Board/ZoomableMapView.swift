import SwiftUI

/// The field map with pinch-zoom, pan, and double-tap zoom. All map gestures are off
/// while `isLocked`; gestures on views layered inside stay active.
struct ZoomableMapView: View {
    let image: UIImage
    let isLocked: Bool

    @State private var viewport = MapViewport()
    /// The viewport when the current pinch/drag began; each change is applied to it.
    @State private var gestureStart: MapViewport?

    var body: some View {
        GeometryReader { proxy in
            let container = CGRect(origin: .zero, size: proxy.size)
            let frame = viewport.imageFrame(imageSize: image.size, in: container)
            Image(uiImage: image)
                .resizable()
                .interpolation(.high)
                .frame(width: frame.width, height: frame.height)
                .position(x: frame.midX, y: frame.midY)
                .contentShape(Rectangle())
                .gesture(panAndZoom(in: container), including: isLocked ? .subviews : .all)
                .gesture(doubleTap(in: container), including: isLocked ? .subviews : .all)
                .onChange(of: proxy.size) {
                    viewport = viewport.clamped(imageSize: image.size, in: container)
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

    private func doubleTap(in container: CGRect) -> some Gesture {
        SpatialTapGesture(count: 2).onEnded { value in
            withAnimation(.snappy) {
                viewport = viewport.toggledZoom(anchor: value.location, imageSize: image.size, in: container)
            }
        }
    }
}
