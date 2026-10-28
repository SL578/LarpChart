import CoreGraphics

/// Converts between normalized map-image coordinates and view space.
///
/// `imageFrame` is where the image is drawn in the view. Zoom and pan only change
/// that frame, so these conversions stay the same at every zoom level.
enum MapGeometry {
    /// The largest rect with the image's aspect ratio that fits in `container`, centered.
    static func aspectFitRect(imageSize: CGSize, in container: CGRect) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return CGRect(origin: CGPoint(x: container.midX, y: container.midY), size: .zero)
        }
        let scale = min(container.width / imageSize.width, container.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
        return CGRect(
            x: container.midX - size.width / 2,
            y: container.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }

    static func toView(_ point: NormalizedPoint, in imageFrame: CGRect) -> CGPoint {
        CGPoint(
            x: imageFrame.minX + point.x * imageFrame.width,
            y: imageFrame.minY + point.y * imageFrame.height
        )
    }

    /// Not clamped: a point outside the image maps outside 0–1. Call `clamped()` if needed.
    static func toNormalized(_ point: CGPoint, in imageFrame: CGRect) -> NormalizedPoint {
        NormalizedPoint(
            x: imageFrame.width > 0 ? (point.x - imageFrame.minX) / imageFrame.width : 0,
            y: imageFrame.height > 0 ? (point.y - imageFrame.minY) / imageFrame.height : 0
        )
    }
}
