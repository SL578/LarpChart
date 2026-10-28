import Foundation
import SwiftData

/// A playing field: a name and its map image. Plans are drawn on top of it.
@Model
final class Field {
    @Attribute(.unique) var id: UUID
    var name: String
    @Attribute(.externalStorage) var imageData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Plan.field)
    var plans: [Plan] = []

    init(name: String, imageData: Data? = nil) {
        self.id = UUID()
        self.name = name
        self.imageData = imageData
        self.createdAt = .now
    }
}
