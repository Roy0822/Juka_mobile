import SwiftUI
import Foundation
import CoreLocation

struct NewsfeedView: View {
    @State private var feed: [GroupActivity] = []
    @State private var selectedActivity: GroupActivity?
    @State private var showActivityDetail = false
    @State private var showChatRoom = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: AppStyles.padding) {
                    ForEach(feed) { activity in
                        GroupActivityCard(
                            activity: activity,
                            distance: calculateDistance(to: activity.location.coordinate)
                        ) {
                            selectedActivity = activity
                            showActivityDetail = true
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("動態")
            .sheet(isPresented: $showActivityDetail, content: {
                if let activity = selectedActivity {
                    FullScreenActivityDetailSheet(
                        activity: activity,
                        onJoin: {
                            showActivityDetail = false
                            showChatRoom = true
                        }
                    )
                }
            })
            .fullScreenCover(isPresented: $showChatRoom, content: {
                if let activity = selectedActivity {
                    FullScreenChatRoomView(
                        activity: activity,
                        isPresented: $showChatRoom
                    )
                }
            })
        }
        .onAppear {
            loadSampleFeed()
        }
    }
    
    // In a real app, this would calculate actual distance
    private func calculateDistance(to coordinate: CLLocationCoordinate2D) -> Double {
        let distances = [150.0, 200.0, 350.0, 500.0, 750.0, 1200.0]
        return distances.randomElement() ?? 200.0
    }
    
    // Sample data function to create sample activities for demonstration
    private func loadSampleFeed() {
        let sampleActivities = [
            GroupActivity(
                title: "星巴克買一送一",
                activityDescription: "大杯拿鐵買一送一，找人一起享用！",
                expiresAt: Date().addingTimeInterval(3600),
                location: Location(latitude: 25.033, longitude: 121.565, placeName: "台北 101"),
                creatorId: "user1",
                creatorName: "吳盛偉",
                type: .coffeeDeal
            ),
            GroupActivity(
                title: "麥當勞分享餐",
                activityDescription: "麥當勞雙人分享餐只要200元，有人要一起嗎？",
                expiresAt: Date().addingTimeInterval(7200),
                location: Location(latitude: 25.036, longitude: 121.568, placeName: "信義商圈"),
                creatorId: "user2",
                creatorName: "李小明",
                type: .foodDeal
            ),
            GroupActivity(
                title: "台北到桃園共乘",
                activityDescription: "晚上8點從台北到桃園，有3個位子，平分車資",
                expiresAt: Date().addingTimeInterval(10800),
                location: Location(latitude: 25.030, longitude: 121.562, placeName: "象山捷運站"),
                creatorId: "user3",
                creatorName: "張小玲",
                type: .rideShare
            ),
            GroupActivity(
                title: "ZARA特價",
                activityDescription: "ZARA全館3折起，一起湊滿$3000免運費！",
                expiresAt: Date().addingTimeInterval(5400),
                location: Location(latitude: 25.038, longitude: 121.563, placeName: "市政府"),
                creatorId: "user4",
                creatorName: "周艾琳",
                type: .shopping
            )
        ]
        
        feed = sampleActivities
    }
}

#Preview {
    NewsfeedView()
} 