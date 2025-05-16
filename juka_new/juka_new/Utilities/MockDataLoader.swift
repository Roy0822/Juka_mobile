import Foundation
import SwiftData

class MockDataLoader {
    static let shared = MockDataLoader()
    
    private init() {}
    
    func loadMockActivities() -> [GroupActivity] {
        guard let url = Bundle.main.url(forResource: "mock_activities", withExtension: "json") else {
            print("無法找到mock_activities.json檔案")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let activitiesData = try decoder.decode([ActivityData].self, from: data)
            return activitiesData.map { activityData in
                // 創建Location對象
                let location = Location(
                    latitude: activityData.location.latitude,
                    longitude: activityData.location.longitude,
                    placeName: activityData.location.placeName
                )
                
                // 創建GroupActivity對象
                let activity = GroupActivity(
                    title: activityData.title,
                    activityDescription: activityData.activityDescription,
                    expiresAt: activityData.expiresAt,
                    location: location,
                    creatorId: activityData.creatorId,
                    creatorName: activityData.creatorName,
                    type: GroupType(rawValue: activityData.type) ?? .foodDeal,
                    participantIds: activityData.participantIds
                )
                
                // 在SwiftData對象創建後設置ID
                activity.id = activityData.id
                activity.isActive = activityData.isActive
                
                // 手動設置創建時間
                if let createdAt = activityData.createdAt {
                    activity.createdAt = createdAt
                }
                
                return activity
            }
        } catch {
            print("加載模擬數據時發生錯誤: \(error)")
            return []
        }
    }
}

// 用於JSON解碼的輔助結構體
struct ActivityData: Codable {
    struct LocationData: Codable {
        let latitude: Double
        let longitude: Double
        let placeName: String?
    }
    
    let id: String
    let title: String
    let activityDescription: String
    let createdAt: Date?
    let expiresAt: Date?
    let location: LocationData
    let creatorId: String
    let creatorName: String
    let participantIds: [String]
    let type: String
    let isActive: Bool
} 