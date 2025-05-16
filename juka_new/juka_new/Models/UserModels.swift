import Foundation
import SwiftData

@Model
final class User {
    var id: String
    var name: String
    var email: String
    var profileImageURL: String?
    var joinedDate: Date
    var rating: Double
    var completedGroups: Int
    var preferences: [String] // Group type strings
    var notificationSettings: NotificationSettings
    var selectedRingIndex: Int // 新增：用戶選擇的戒指索引
    
    init(
        id: String,
        name: String,
        email: String,
        profileImageURL: String? = nil,
        joinedDate: Date = Date(),
        rating: Double = 5.0,
        completedGroups: Int = 0,
        preferences: [String] = [],
        notificationSettings: NotificationSettings = NotificationSettings(),
        selectedRingIndex: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.profileImageURL = profileImageURL
        self.joinedDate = joinedDate
        self.rating = rating
        self.completedGroups = completedGroups
        self.preferences = preferences
        self.notificationSettings = notificationSettings
        self.selectedRingIndex = selectedRingIndex
    }
}

struct NotificationSettings: Codable {
    var nearbyGroups: Bool = true
    var messages: Bool = true
    var groupUpdates: Bool = true
    var promotions: Bool = true
    var maxDistance: Double = 1000 // 公尺
} 