import CoreGraphics
import Foundation

/// A point in normalized map-image coordinates: 0–1 on each axis of the field image.
/// Used instead of `CGPoint` in stored data so the encoded format stays stable
/// (it also becomes the web viewer's JSON format).
struct NormalizedPoint: Codable, Hashable {
    var x: Double
    var y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    init(_ point: CGPoint) {
        self.init(x: Double(point.x), y: Double(point.y))
    }

    var cgPoint: CGPoint { CGPoint(x: x, y: y) }

    /// The same point pulled inside the image bounds.
    func clamped() -> NormalizedPoint {
        NormalizedPoint(x: min(max(x, 0), 1), y: min(max(y, 0), 1))
    }
}

/// Where one unit sits during one phase.
struct UnitState: Codable, Hashable {
    var unitID: UUID
    var position: NormalizedPoint
}

/// A drawn arrow. Lives in the phase where the move starts: an arrow in Phase 1
/// describes the move from Phase 1 to Phase 2, so it is not copied forward.
struct Arrow: Codable, Hashable, Identifiable {
    enum Style: String, Codable, CaseIterable {
        case route
        case attack
        case zoneEdge
    }

    var id: UUID = UUID()
    var unitID: UUID?
    var path: [NormalizedPoint]
    var style: Style = .route
}

/// One named member of a saved roster.
struct RosterMember: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var defaultUnitType: UnitType = .rifleman
}
