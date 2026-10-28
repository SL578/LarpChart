import CoreGraphics

/// Zoom and pan for the board. Produces the `imageFrame` that `MapGeometry` converts
/// against, so everything drawn on the map follows it at every zoom level.
///
/// `offset` moves the image's center away from the container's center, in view points.
struct MapViewport: Equatable {
    static let minScale: CGFloat = 1
    static let maxScale: CGFloat = 8
    static let doubleTapScale: CGFloat = 2

    var scale: CGFloat = 1
    var offset: CGSize = .zero

    func imageFrame(imageSize: CGSize, in container: CGRect) -> CGRect {
        let fit = MapGeometry.aspectFitRect(imageSize: imageSize, in: container)
        let size = CGSize(width: fit.width * scale, height: fit.height * scale)
        return CGRect(
            x: fit.midX + offset.width - size.width / 2,
            y: fit.midY + offset.height - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    /// Zooms by `factor`, keeping the map point under `anchor` (a view point) in place.
    func zoomed(by factor: CGFloat, anchor: CGPoint, imageSize: CGSize, in container: CGRect) -> MapViewport {
        let newScale = min(max(scale * factor, Self.minScale), Self.maxScale)
        let ratio = newScale / scale
        let center = CGPoint(x: container.midX + offset.width, y: container.midY + offset.height)
        let newCenter = CGPoint(
            x: anchor.x - ratio * (anchor.x - center.x),
            y: anchor.y - ratio * (anchor.y - center.y)
        )
        let zoomed = MapViewport(
            scale: newScale,
            offset: CGSize(width: newCenter.x - container.midX, height: newCenter.y - container.midY)
        )
        return zoomed.clamped(imageSize: imageSize, in: container)
    }

    func panned(by translation: CGSize, imageSize: CGSize, in container: CGRect) -> MapViewport {
        let panned = MapViewport(
            scale: scale,
            offset: CGSize(width: offset.width + translation.width, height: offset.height + translation.height)
        )
        return panned.clamped(imageSize: imageSize, in: container)
    }

    /// Keeps the map covering the container on any axis where it is larger,
    /// and centered on any axis where it is smaller.
    func clamped(imageSize: CGSize, in container: CGRect) -> MapViewport {
        let fit = MapGeometry.aspectFitRect(imageSize: imageSize, in: container)
        let clampedScale = min(max(scale, Self.minScale), Self.maxScale)
        let maxX = max(0, (fit.width * clampedScale - container.width) / 2)
        let maxY = max(0, (fit.height * clampedScale - container.height) / 2)
        return MapViewport(
            scale: clampedScale,
            offset: CGSize(
                width: min(max(offset.width, -maxX), maxX),
                height: min(max(offset.height, -maxY), maxY)
            )
        )
    }

    /// Double-tap: back to fit when zoomed in, otherwise zoom in around `anchor`.
    func toggledZoom(anchor: CGPoint, imageSize: CGSize, in container: CGRect) -> MapViewport {
        if scale > Self.minScale { return MapViewport() }
        return zoomed(by: Self.doubleTapScale, anchor: anchor, imageSize: imageSize, in: container)
    }
}
