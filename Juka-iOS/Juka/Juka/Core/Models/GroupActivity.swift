import Foundation
import SwiftData
import CoreLocation

@Model
final class GroupActivity {
    var id: UUID
    var title: String
    var activityDescription: String
    var createdAt: Date
    var expiresAt: Date?
    var location: Location
    var creatorId: String
    var creatorName: String
    var participantIds: [String]
    var maxParticipants: Int?
    var status: GroupStatus
    var type: GroupType
    var imageURL: URL?
    
    init(
        id: UUID = UUID(),
        title: String,
        activityDescription: String,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        location: Location,
        creatorId: String,
        creatorName: String,
        participantIds: [String] = [],
        maxParticipants: Int? = nil,
        status: GroupStatus = .active,
        type: GroupType,
        imageURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.activityDescription = activityDescription
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.location = location
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.participantIds = participantIds
        self.maxParticipants = maxParticipants
        self.status = status
        self.type = type
        self.imageURL = imageURL
    }
}

enum GroupStatus: String, Codable {
    case active
    case completed
    case expired
    case cancelled
}

enum GroupType: String, Codable {
    case coffeeDeal
    case foodDeal
    case rideShare
    case shopping
    case other
}

@Model
final class Location {
    var latitude: Double
    var longitude: Double
    var address: String?
    var placeName: String?
    
    init(latitude: Double, longitude: Double, address: String? = nil, placeName: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.placeName = placeName
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
} 