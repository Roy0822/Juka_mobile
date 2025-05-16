import Foundation
import SwiftData
import MapKit
import CoreLocation
import SwiftUI

enum GroupType: String, Codable, CaseIterable {
    case coffeeDeal
    case foodDeal
    case groceryShopping
    case textbookExchange
    case rideShare
    
    var icon: String {
        switch self {
        case .coffeeDeal:
            return "cup.and.saucer.fill"
        case .foodDeal:
            return "fork.knife"
        case .groceryShopping:
            return "cart.fill"
        case .textbookExchange:
            return "book.fill"
        case .rideShare:
            return "car.fill"
        }
    }
    
    var displayName: String {
        switch self {
        case .coffeeDeal:
            return "咖啡優惠"
        case .foodDeal:
            return "餐飲優惠"
        case .groceryShopping:
            return "團購食材"
        case .textbookExchange:
            return "教材交換"
        case .rideShare:
            return "共乘服務"
        }
    }
    
    var color: Color {
        switch self {
        case .coffeeDeal:
            return Color(#colorLiteral(red: 0.765, green: 0.608, blue: 0.459, alpha: 1))
        case .foodDeal:
            return Color(#colorLiteral(red: 0.851, green: 0.463, blue: 0.416, alpha: 1))
        case .groceryShopping:
            return Color(#colorLiteral(red: 0.412, green: 0.596, blue: 0.427, alpha: 1))
        case .textbookExchange:
            return Color(#colorLiteral(red: 0.459, green: 0.573, blue: 0.733, alpha: 1))
        case .rideShare:
            return Color(#colorLiteral(red: 0.592, green: 0.459, blue: 0.733, alpha: 1))
        }
    }
}

enum OrderTimeType: String, Codable, CaseIterable {
    case immediate  // 立即訂單，使用倒數計時
    case scheduled  // 預約訂單，使用指定日期時間
    
    var displayName: String {
        switch self {
        case .immediate:
            return "立即訂單"
        case .scheduled:
            return "預約訂單"
        }
    }
}

@Model
final class GroupActivity {
    var id: String
    var title: String
    var activityDescription: String
    var createdAt: Date
    var expiresAt: Date? // 對於立即訂單，這是倒數結束時間；對於預約訂單，這是活動開始時間
    var scheduledEndTime: Date? // 僅用於預約訂單的結束時間
    var orderTimeType: String // 使用 OrderTimeType 的 rawValue
    var location: Location
    var creatorId: String
    var creatorName: String
    var participantIds: [String]
    var typeRawValue: String // 存儲 GroupType 的原始值
    var isActive: Bool
    
    init(
        title: String,
        activityDescription: String,
        orderTimeType: OrderTimeType = .immediate,
        expiresAt: Date? = nil,
        scheduledEndTime: Date? = nil,
        location: Location,
        creatorId: String,
        creatorName: String,
        type: GroupType,
        participantIds: [String] = []
    ) {
        self.id = UUID().uuidString
        self.title = title
        self.activityDescription = activityDescription
        self.createdAt = Date()
        self.orderTimeType = orderTimeType.rawValue
        self.expiresAt = expiresAt
        self.scheduledEndTime = scheduledEndTime
        self.location = location
        self.creatorId = creatorId
        self.creatorName = creatorName
        self.participantIds = participantIds
        self.typeRawValue = type.rawValue
        self.isActive = true
    }
    
    // 計算屬性，獲取 GroupType
    var type: GroupType {
        get {
            return GroupType(rawValue: typeRawValue) ?? .foodDeal
        }
        set {
            typeRawValue = newValue.rawValue
        }
    }
    
    // 輔助方法：判斷是否為立即訂單
    var isImmediateOrder: Bool {
        return orderTimeType == OrderTimeType.immediate.rawValue
    }
    
    // 輔助方法：判斷是否為預約訂單
    var isScheduledOrder: Bool {
        return orderTimeType == OrderTimeType.scheduled.rawValue
    }
    
    // 格式化顯示時間
    func formattedTimeDisplay() -> String {
        if isImmediateOrder {
            // 立即訂單顯示剩餘時間
            if let expiresAt = expiresAt {
                let remainingTime = expiresAt.timeIntervalSince(Date())
                if remainingTime <= 0 {
                    return "已結束"
                }
                
                let hours = Int(remainingTime) / 3600
                let minutes = (Int(remainingTime) % 3600) / 60
                
                if hours > 0 {
                    return "剩餘 \(hours) 小時 \(minutes) 分鐘"
                } else {
                    return "剩餘 \(minutes) 分鐘"
                }
            }
            return "無限期"
        } else {
            // 預約訂單顯示具體日期時間
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            
            if let startTime = expiresAt {
                if let endTime = scheduledEndTime {
                    return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
                }
                return formatter.string(from: startTime)
            }
            return "未設定時間"
        }
    }
}

class GroupTypeTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        guard let groupType = value as? GroupType else { return nil }
        return groupType.rawValue
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let stringValue = value as? String,
              let groupType = GroupType(rawValue: stringValue) else { return nil }
        return groupType
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            GroupTypeTransformer(),
            forName: NSValueTransformerName(String(describing: GroupTypeTransformer.self))
        )
    }
}

@Model
final class Location {
    var id: String
    var latitude: Double
    var longitude: Double
    var placeName: String?
    var address: String?
    
    init(
        latitude: Double,
        longitude: Double,
        placeName: String? = nil,
        address: String? = nil
    ) {
        self.id = UUID().uuidString
        self.latitude = latitude
        self.longitude = longitude
        self.placeName = placeName
        self.address = address
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

@Model
final class ChatMessage {
    var id: String
    var groupId: String
    var senderId: String
    var senderName: String
    var content: String
    var timestamp: Date
    var isRead: Bool
    
    init(
        groupId: String,
        senderId: String,
        senderName: String,
        content: String,
        isRead: Bool = false
    ) {
        self.id = UUID().uuidString
        self.groupId = groupId
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.timestamp = Date()
        self.isRead = isRead
    }
} 