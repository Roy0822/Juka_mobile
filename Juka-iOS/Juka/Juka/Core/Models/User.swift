import Foundation
import SwiftData

@Model
final class User {
    var id: String
    var name: String
    var profileImageURL: URL?
    var joinedDate: Date
    var rating: Double
    var completedGroups: Int
    var preferences: [GroupType]
    var notificationSettings: NotificationSettings
    
    init(
        id: String,
        name: String,
        profileImageURL: URL? = nil,
        joinedDate: Date = Date(),
        rating: Double = 5.0,
        completedGroups: Int = 0,
        preferences: [GroupType] = [],
        notificationSettings: NotificationSettings = NotificationSettings()
    ) {
        self.id = id
        self.name = name
        self.profileImageURL = profileImageURL
        self.joinedDate = joinedDate
        self.rating = rating
        self.completedGroups = completedGroups
        self.preferences = preferences
        self.notificationSettings = notificationSettings
    }
}

struct NotificationSettings: Codable {
    var nearbyGroups: Bool = true
    var messages: Bool = true
    var groupUpdates: Bool = true
    var promotions: Bool = true
    var maxDistance: Double = 1000 // meters
} 