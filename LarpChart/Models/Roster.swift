import Foundation
import SwiftData

/// A saved squad list, ready to drop onto a plan.
@Model
final class Roster {
    @Attribute(.unique) var id: UUID
    var name: String
    var members: [RosterMember]

    init(name: String, members: [RosterMember] = []) {
        self.id = UUID()
        self.name = name
        self.members = members
    }
}
