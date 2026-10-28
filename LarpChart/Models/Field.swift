import Foundation
import SwiftData

/// A playing field: a name and its map image. Plans are drawn on top of it.
@Model
final class Field {
    @Attribute(.unique) var id: UUID
    var name: String
    @Attribute(.externalStorage) var imageData: Data?
    /// Small preview for the field library, so the list never decodes full maps.
    var thumbnailData: Data?
    /// When locked, pan and zoom are off so drawing never moves the map.
    var isMapLocked: Bool = false
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Plan.field)
    var plans: [Plan] = []

    init(name: String, imageData: Data? = nil, thumbnailData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.createdAt = .now
    }
}
