import SwiftUI
import CoreLocation
import MapKit
import UIKit // For URL opening

struct ExploreView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var searchText = ""
    @State private var selectedCategory: GroupType?
    @State private var showActivityDetail = false
    @State private var showGroupStatus = false
    @State private var showChatRoom = false
    @State private var selectedActivity: GroupActivity?
    @State private var activities: [GroupActivity] = []
    @State private var showActivityDetails = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient for the entire view
                Rectangle()
                    .fill(AppStyles.primaryGradient.opacity(0.15))
                    .ignoresSafeArea()
                    
                ScrollView {
                    VStack(alignment: .leading) {
                        // Search bar
                        SearchBar(text: $searchText)
                            .padding(.horizontal)
                        
                        // Category filter
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppStyles.smallPadding) {
                                CategoryButton(
                                    title: "全部",
                                    iconName: "square.grid.2x2.fill",
                                    color: .purple,
                                    isSelected: selectedCategory == nil
                                ) {
                                    selectedCategory = nil
                                }
                                
                                CategoryButton(
                                    title: "咖啡",
                                    iconName: "cup.and.saucer.fill",
                                    color: .brown,
                                    isSelected: selectedCategory == .coffeeDeal
                                ) {
                                    selectedCategory = .coffeeDeal
                                }
                                
                                CategoryButton(
                                    title: "美食",
                                    iconName: "fork.knife",
                                    color: .orange,
                                    isSelected: selectedCategory == .foodDeal
                                ) {
                                    selectedCategory = .foodDeal
                                }
                                
                                CategoryButton(
                                    title: "共乘",
                                    iconName: "car.fill",
                                    color: .blue,
                                    isSelected: selectedCategory == .rideShare
                                ) {
                                    selectedCategory = .rideShare
                                }
                                
                                CategoryButton(
                                    title: "購物",
                                    iconName: "bag.fill",
                                    color: .green,
                                    isSelected: selectedCategory == .shopping
                                ) {
                                    selectedCategory = .shopping
                                }
                                
                                CategoryButton(
                                    title: "其他",
                                    iconName: "ellipsis.circle.fill",
                                    color: .gray,
                                    isSelected: selectedCategory == .other
                                ) {
                                    selectedCategory = .other
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Featured section
                        VStack(alignment: .leading) {
                            Text("熱門揪團")
                                .font(AppStyles.Typography.subtitle)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppStyles.padding) {
                                    ForEach(filteredActivities.prefix(5)) { activity in
                                        FeaturedActivityCard(activity: activity) {
                                            selectedActivity = activity
                                            showActivityDetails = true
                                        }
                                        .frame(width: 300, height: 200)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                        
                        // Recent activities
                        VStack(alignment: .leading) {
                            Text("最新揪團")
                                .font(AppStyles.Typography.subtitle)
                                .padding(.horizontal)
                            
                            ForEach(filteredActivities) { activity in
                                GroupActivityCard(
                                    activity: activity,
                                    distance: calculateDistance(to: activity.location.coordinate)
                                ) {
                                    selectedActivity = activity
                                    showActivityDetails = true
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            }
                        }
                        .padding(.top)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("探索")
            .sheet(isPresented: $showGroupStatus) {
                if let activity = selectedActivity {
                    GroupStatusView(activity: activity)
                }
            }
            .sheet(isPresented: $showActivityDetails) {
                if let activity = selectedActivity {
                    NavigationStack {
                        ScrollView {
                            GroupPreviewView(activity: activity, onJoinPressed: {
                                selectedActivity = activity
                                showActivityDetails = false
                                showGroupStatus = true
                            })
                            .padding()
                        }
                        .navigationTitle("揪團詳情")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("關閉") {
                                    showActivityDetails = false
                                }
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showChatRoom, content: {
                if let activity = selectedActivity {
                    ChatRoomView(
                        activity: activity,
                        isPresented: $showChatRoom
                    )
                }
            })
        }
        .onAppear {
            loadSampleData()
        }
    }
    
    private var filteredActivities: [GroupActivity] {
        var result = activities
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter { activity in
                activity.title.localizedCaseInsensitiveContains(searchText) ||
                activity.activityDescription.localizedCaseInsensitiveContains(searchText) ||
                (activity.location.placeName?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        // Filter by category
        if let selectedCategory {
            result = result.filter { $0.type == selectedCategory }
        }
        
        return result
    }
    
    // In a real app, this would calculate actual distance
    private func calculateDistance(to coordinate: CLLocationCoordinate2D) -> Double {
        let distances = [150.0, 200.0, 350.0, 500.0, 750.0, 1200.0]
        return distances.randomElement() ?? 200.0
    }
    
    private func loadSampleData() {
        // In a real app, this would fetch data from a server
        let locations = [
            Location(latitude: 25.033, longitude: 121.565, placeName: "台北 101"),
            Location(latitude: 25.036, longitude: 121.568, placeName: "信義商圈"),
            Location(latitude: 25.030, longitude: 121.562, placeName: "象山捷運站"),
            Location(latitude: 25.038, longitude: 121.563, placeName: "市政府")
        ]
        
        activities = [
            GroupActivity(
                title: "星巴克買一送一",
                activityDescription: "限時優惠！大杯拿鐵買一送一，找人一起分享",
                expiresAt: Date().addingTimeInterval(3600),
                location: locations[0],
                creatorId: "user1",
                creatorName: "吳盛偉",
                type: .coffeeDeal
            ),
            GroupActivity(
                title: "鼎泰豐午餐團",
                activityDescription: "人多划算！五人以上九折優惠，現在還有兩個名額",
                expiresAt: Date().addingTimeInterval(7200),
                location: locations[1],
                creatorId: "user2",
                creatorName: "林小美",
                type: .foodDeal
            ),
            GroupActivity(
                title: "共乘去陽明山",
                activityDescription: "週末要去陽明山踏青，有3個空位，願意平攤油錢",
                expiresAt: Date().addingTimeInterval(86400),
                location: locations[2],
                creatorId: "user3",
                creatorName: "張大方",
                type: .rideShare
            ),
            GroupActivity(
                title: "好市多購物分享",
                activityDescription: "週日去好市多採購，可以幫忙帶東西，有需要的跟我說",
                expiresAt: Date().addingTimeInterval(43200),
                location: locations[3],
                creatorId: "user4",
                creatorName: "陳明德",
                type: .shopping
            )
        ]
    }
}

struct CategoryButton: View {
    let title: String
    let iconName: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? color : Color(.systemGray5))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? color : .primary)
            }
        }
    }
}

struct FeaturedActivityCard: View {
    let activity: GroupActivity
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                // Image or placeholder with gradient overlay
                ZStack(alignment: .topTrailing) {
                    // Image placeholder - could be replaced with actual image in a real app
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    typeColor.opacity(0.5),
                                    typeColor.opacity(0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            Image(systemName: iconName)
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.15))
                        )
                    
                    // Type badge
                    ZStack {
                        Capsule()
                            .fill(typeColor)
                            .frame(width: 80, height: 28)
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: iconName)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                            
                            Text(typeName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(12)
                }
                
                // Main content with gradient background
                VStack(alignment: .leading, spacing: 8) {
                    // Title and location
                    VStack(alignment: .leading, spacing: 2) {
                        Text(activity.title)
                            .font(AppStyles.Typography.subtitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text(activity.location.placeName ?? "")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    // Creator and time
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Text(String(activity.creatorName.first ?? "?"))
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            Text(activity.creatorName)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                        
                        Spacer()
                        
                        if let expiresAt = activity.expiresAt {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.caption2)
                                
                                Text(timeRemaining(from: expiresAt))
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        }
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [
                            typeColor,
                            typeColor.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: AppStyles.cornerRadius))
            .shadow(
                color: typeColor.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
            .aspectRatio(16/9, contentMode: .fit)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        switch activity.type {
        case .coffeeDeal:
            return "cup.and.saucer.fill"
        case .foodDeal:
            return "fork.knife"
        case .rideShare:
            return "car.fill"
        case .shopping:
            return "bag.fill"
        case .other:
            return "star.fill"
        }
    }
    
    private var typeName: String {
        switch activity.type {
        case .coffeeDeal:
            return "咖啡"
        case .foodDeal:
            return "美食"
        case .rideShare:
            return "共乘"
        case .shopping:
            return "購物"
        case .other:
            return "其他"
        }
    }
    
    private var typeColor: Color {
        switch activity.type {
        case .coffeeDeal:
            return Color.brown
        case .foodDeal:
            return Color.orange
        case .rideShare:
            return Color.blue
        case .shopping:
            return Color.green
        case .other:
            return Color.purple
        }
    }
    
    private func timeRemaining(from date: Date) -> String {
        let interval = date.timeIntervalSince(Date())
        
        if interval <= 0 {
            return "已過期"
        }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "剩餘\(hours)小時"
        } else {
            return "剩餘\(minutes)分鐘"
        }
    }
}

#Preview {
    ExploreView()
} 