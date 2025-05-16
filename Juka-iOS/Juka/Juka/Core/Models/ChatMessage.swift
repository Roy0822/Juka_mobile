import Foundation
import SwiftData

@Model
final class ChatMessage {
    var id: UUID
    var groupId: UUID
    var senderId: String
    var senderName: String
    var content: String
    var timestamp: Date
    var isRead: Bool
    var expiresAt: Date?
    
    init(
        id: UUID = UUID(),
        groupId: UUID,
        senderId: String,
        senderName: String,
        content: String,
        timestamp: Date = Date(),
        isRead: Bool = false,
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.groupId = groupId
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
        self.expiresAt = expiresAt
    }
}
