import SwiftUI
import MapKit
import UIKit // For URL opening
import CoreLocation

// 確保在 Info.plist 中添加以下配置:
// NSLocationWhenInUseUsageDescription: 需要您的位置以在地圖上顯示您的位置和附近的活動
// NSLocationAlwaysAndWhenInUseUsageDescription: 需要您的位置以在地圖上顯示您的位置，並在背景中提供附近活動的通知
// NSLocationAlwaysUsageDescription: 需要您的位置以在地圖上顯示您的位置，並在背景中提供附近活動的通知
// UIBackgroundModes: location

// Location Manager class to handle permissions and location updates
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus
    
    override init() {
        authorizationStatus = .notDetermined
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func requestLocationPermissions() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestBackgroundPermissions() {
        locationManager.requestAlwaysAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

// Add an enum to represent the active sheet
enum ActiveSheet: Identifiable {
    case createGroup
    case activityDetails
    case groupStatus
    case chatRoom
    case messageList
    
    var id: Int {
        switch self {
        case .createGroup: return 0
        case .activityDetails: return 1
        case .groupStatus: return 2
        case .chatRoom: return 3
        case .messageList: return 4
        }
    }
}

struct MapView: View {
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var locationManager = LocationManager()
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.033, longitude: 121.565),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    @State private var mapSelection: GroupActivity?
    @State private var selectedActivity: GroupActivity?
    @State private var drawerState: DrawerState = .halfExpanded
    @State private var activeSheet: ActiveSheet?
    @State private var showNotification = false
    @State private var notificationActivity: GroupActivity?
    @State private var chatActivity: GroupActivity?
    @State private var activities: [GroupActivity] = []
    @State private var initialPositionSet = false
    @State private var showRadiusSlider = false
    
    // 附近範圍半徑（公尺）
    @State private var nearbyRadius: Double = 500
    private let minRadius: Double = 100
    private let maxRadius: Double = 2000
    
    private let minDrawerHeight: CGFloat = 150
    private let halfDrawerHeight: CGFloat = 300
    private let maxDrawerHeight: CGFloat = 600
    
    var body: some View {
        ZStack {
            // Map
            Map(position: $cameraPosition, selection: $mapSelection) {
                // User location
                if let userLocation = locationManager.userLocation {
                    UserAnnotation()
                    
                    // 添加用戶位置周圍的圓形區域
                    MapCircle(
                        center: userLocation.coordinate,
                        radius: nearbyRadius
                    )
                    .foregroundStyle(AppStyles.primary.opacity(0.15))
                    .stroke(AppStyles.primary.opacity(0.3), lineWidth: 2)
                }
                
                // Activity markers
                ForEach(activities) { activity in
                    Marker(activity.title, coordinate: activity.location.coordinate)
                        .tint(markerColor(for: activity.type))
                        .tag(activity)
                }
            }
            .ignoresSafeArea()
            .onChange(of: mapSelection) { _, newValue in
                withAnimation {
                    if newValue != nil {
                        selectedActivity = newValue
                        activeSheet = .activityDetails
                    }
                }
            }
            .mapStyle(colorScheme == .dark ? .standard(elevation: .realistic, emphasis: .muted) : .standard)
            .mapControls {
                // 空的 mapControls 修飾符會移除所有預設控制元素，包括指南針
            }
            .onAppear {
                locationManager.requestLocationPermissions()
                // After a short delay, also request background permission
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    locationManager.requestBackgroundPermissions()
                }
            }
            .onChange(of: locationManager.userLocation) { _, newLocation in
                // 只有在初次獲取位置時更新地圖位置
                if !initialPositionSet, let userLocation = newLocation {
                    initialPositionSet = true
                    withAnimation {
                        cameraPosition = .region(
                            MKCoordinateRegion(
                                center: userLocation.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            )
                        )
                    }
                }
            }
            
            // Drawer View - now only shows the list view
            DrawerView(
                state: $drawerState,
                minHeight: minDrawerHeight,
                halfHeight: halfDrawerHeight,
                maxHeight: maxDrawerHeight
            ) {
                VStack {
                    // 搜索範圍調整滑桿
                    NearbyActivitiesListView(
                        activities: activities, 
                        onActivitySelected: { activity in
                            mapSelection = activity
                            selectedActivity = activity
                            activeSheet = .activityDetails
                            withAnimation {
                                cameraPosition = .region(
                                    MKCoordinateRegion(
                                        center: activity.location.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                    )
                                )
                            }
                        }, 
                        showRadiusSlider: $showRadiusSlider,
                        nearbyRadius: $nearbyRadius,
                        minRadius: minRadius,
                        maxRadius: maxRadius,
                        onResetLocation: {
                            withAnimation {
                                // Center on user location if available
                                if let userLocation = locationManager.userLocation {
                                    cameraPosition = .region(
                                        MKCoordinateRegion(
                                            center: userLocation.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    )
                                } else {
                                    // Default location if user location not available
                                    cameraPosition = .region(
                                        MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: 25.033, longitude: 121.565),
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    )
                                }
                            }
                        }
                    )
                }
            }
            .onChange(of: drawerState) { _, newState in
                if newState == .fullyExpanded {
                    withAnimation {
                        showNotification = false
                    }
                }
            }
            
            // Floating navigation bar at top
            VStack {
                HStack {
                    // 移除位置按鈕，將它移動到 drawer 的搜尋欄旁邊
                    Spacer()
                    
                    Button {
                        activeSheet = .messageList
                    } label: {
                        Image(systemName: "bubble.left.fill")
                            .font(.headline)
                            .padding(10)
                            .background(AppStyles.background)
                            .clipShape(Circle())
                            .shadow(color: AppStyles.shadowColor, radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
                
                Spacer()
            }
            
            // Floating action button
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    // Only show FAB when drawer is not fully expanded
                    if drawerState != .fullyExpanded {
                        FloatingActionButton {
                            activeSheet = .createGroup
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, drawerHeight + 20)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .animation(AppStyles.animation, value: drawerState)
            
            // Notification
            if showNotification, let notificationActivity {
                VStack {
                    NotificationCard(
                        activity: notificationActivity,
                        creatorName: notificationActivity.creatorName,
                        distance: 200,
                        onAccept: {
                            showNotification = false
                            selectedActivity = notificationActivity
                            activeSheet = .activityDetails
                        },
                        onDecline: {
                            showNotification = false
                        }
                    )
                    .padding()
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Chat Room
            if activeSheet == .chatRoom, let chatActivity = selectedActivity ?? chatActivity {
                ChatRoomView(
                    activity: chatActivity,
                    isPresented: Binding(
                        get: { activeSheet == .chatRoom },
                        set: { if !$0 { activeSheet = nil } }
                    )
                )
                .transition(.move(edge: .bottom))
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .createGroup:
                CreateGroupView(
                    isPresented: Binding(
                        get: { activeSheet == .createGroup },
                        set: { if !$0 { activeSheet = nil } }
                    ), 
                    onGroupCreated: { newActivity in
                        activities.append(newActivity)
                        selectedActivity = newActivity
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            activeSheet = .groupStatus
                        }
                    }
                )
                
            case .activityDetails:
                if let activity = selectedActivity {
                    NavigationStack {
                        ScrollView {
                            GroupPreviewView(
                                activity: activity, 
                                onJoinPressed: {
                                    activeSheet = nil
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        activeSheet = .groupStatus
                                    }
                                }
                            )
                            .padding()
                        }
                        .navigationTitle("揪團詳情")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("關閉") {
                                    activeSheet = nil
                                }
                            }
                        }
                    }
                }
                
            case .groupStatus:
                if let activity = selectedActivity {
                    GroupStatusView(activity: activity)
                }
                
            case .chatRoom:
                if let activity = selectedActivity {
                    ChatRoomView(
                        activity: activity,
                        isPresented: Binding(
                            get: { activeSheet == .chatRoom },
                            set: { if !$0 { activeSheet = nil } }
                        )
                    )
                }
                
            case .messageList:
                NavigationStack {
                    MessageListView(
                        activities: activities.filter { $0.participantIds.contains("currentUser") || $0.creatorId == "currentUser" },
                        onSelectChat: { activity in
                            selectedActivity = activity
                            activeSheet = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                activeSheet = .chatRoom
                            }
                        }
                    )
                    .navigationTitle("訊息")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("關閉") {
                                activeSheet = nil
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            loadSampleData()
            
            // Show a notification after a delay for demo purposes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let activity = activities.first {
                    notificationActivity = activity
                    withAnimation {
                        showNotification = true
                    }
                }
            }
        }
    }
    
    private var drawerHeight: CGFloat {
        switch drawerState {
        case .collapsed:
            return minDrawerHeight
        case .halfExpanded:
            return halfDrawerHeight
        case .fullyExpanded:
            return maxDrawerHeight
        }
    }
    
    private func markerColor(for type: GroupType) -> Color {
        switch type {
        case .coffeeDeal:
            return .brown
        case .foodDeal:
            return .orange
        case .rideShare:
            return .blue
        case .shopping:
            return .green
        case .other:
            return .purple
        }
    }
    
    private func loadSampleData() {
        // Create sample data for demo
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

// Moving GroupPreviewView to its own file in UI/Components
// See created file: Juka/UI/Components/GroupPreviewView.swift

struct NearbyActivitiesListView: View {
    let activities: [GroupActivity]
    let onActivitySelected: (GroupActivity) -> Void
    @State private var searchText = ""
    @State private var selectedCategory: GroupType?
    @Binding var showRadiusSlider: Bool
    @Binding var nearbyRadius: Double
    let minRadius: Double
    let maxRadius: Double
    let onResetLocation: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Search bar and radius adjust button
            HStack(spacing: 12) {
                // 位置重置按鈕
                Button(action: onResetLocation) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        )
                }
                
                SearchBar(text: $searchText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38) // 使搜尋欄高度一致
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showRadiusSlider.toggle()
                    }
                } label: {
                    Image(systemName: showRadiusSlider ? "ruler.fill" : "ruler")
                        .font(.system(size: 18))
                        .foregroundColor(showRadiusSlider ? AppStyles.primary : .secondary)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        )
                }
            }
            .padding(.horizontal)
            
            // 範圍調整滑桿
            if showRadiusSlider {
                VStack(spacing: 8) {
                    HStack {
                        Text("搜尋範圍:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $nearbyRadius, in: minRadius...maxRadius, step: 100)
                            .accentColor(AppStyles.primary)
                        
                        Text("\(Int(nearbyRadius))m")
                            .font(.caption)
                            .foregroundColor(.primary)
                            .frame(width: 50, alignment: .trailing)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 4)
            }
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryFilterButton(
                        title: "全部",
                        iconName: "square.grid.2x2.fill",
                        color: .purple,
                        isSelected: selectedCategory == nil
                    ) {
                        withAnimation {
                            selectedCategory = nil
                        }
                    }
                    
                    CategoryFilterButton(
                        title: "咖啡",
                        iconName: "cup.and.saucer.fill",
                        color: .brown,
                        isSelected: selectedCategory == .coffeeDeal
                    ) {
                        withAnimation {
                            selectedCategory = .coffeeDeal
                        }
                    }
                    
                    CategoryFilterButton(
                        title: "美食",
                        iconName: "fork.knife",
                        color: .orange,
                        isSelected: selectedCategory == .foodDeal
                    ) {
                        withAnimation {
                            selectedCategory = .foodDeal
                        }
                    }
                    
                    CategoryFilterButton(
                        title: "共乘",
                        iconName: "car.fill",
                        color: .blue,
                        isSelected: selectedCategory == .rideShare
                    ) {
                        withAnimation {
                            selectedCategory = .rideShare
                        }
                    }
                    
                    CategoryFilterButton(
                        title: "購物",
                        iconName: "bag.fill",
                        color: .green,
                        isSelected: selectedCategory == .shopping
                    ) {
                        withAnimation {
                            selectedCategory = .shopping
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
            
            // Activity count header
            HStack {
                Text("\(filteredActivities.count) 個揪團在附近")
                    .font(AppStyles.Typography.subtitle)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Sort button (could be implemented later)
                Button(action: {}) {
                    Label("排序", systemImage: "arrow.up.arrow.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .controlSize(.small)
            }
            .padding(.horizontal)
            
            if filteredActivities.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary.opacity(0.5))
                    
                    Text(selectedCategory != nil ? "找不到此類型的揪團" : "附近沒有揪團")
                        .font(AppStyles.Typography.body)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(height: 200)
            } else {
                // Activity list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredActivities) { activity in
                            GroupActivityCard(
                                activity: activity,
                                distance: calculateDistance(to: activity.location.coordinate)
                            ) {
                                onActivitySelected(activity)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
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
}

struct CategoryFilterButton: View {
    let title: String
    let iconName: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? color.opacity(0.2) : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? color : .secondary)
            .overlay(
                Capsule()
                    .stroke(isSelected ? color : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct ChatRoomView: View {
    let activity: GroupActivity
    @Binding var isPresented: Bool
    @State private var messageText = ""
    @State private var messages: [Juka.ChatMessage] = []
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                ChatRoomHeader(
                    activity: activity,
                    participantCount: activity.participantIds.count + 1,
                    onClose: {
                        withAnimation {
                            isPresented = false
                        }
                    }
                )
                
                if messages.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Text("開始與其他參與者交流吧！")
                            .font(AppStyles.Typography.body)
                            .foregroundColor(.secondary)
                        
                        ExpirableMessageLabel(isUserMessage: false)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        ForEach(messages) { message in
                            ChatMessageView(
                                message: message,
                                isCurrentUser: message.senderId == "currentUser"
                            )
                        }
                        
                        ExpirableMessageLabel(isUserMessage: true)
                            .padding(.bottom, 8)
                    }
                }
                
                ChatInputView(messageText: $messageText) {
                    sendMessage()
                }
            }
        }
        .onAppear {
            // Add sample message after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let welcomeMessage = Juka.ChatMessage(
                    groupId: activity.id,
                    senderId: activity.creatorId,
                    senderName: activity.creatorName,
                    content: "歡迎加入！我在\(activity.location.placeName ?? "這裡")等你，大概什麼時候到呢？"
                )
                messages.append(welcomeMessage)
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = Juka.ChatMessage(
            groupId: activity.id,
            senderId: "currentUser",
            senderName: "我",
            content: messageText
        )
        
        withAnimation {
            messages.append(newMessage)
            messageText = ""
        }
        
        // Simulate reply after a delay
        if messages.count == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let replyMessage = Juka.ChatMessage(
                    groupId: activity.id,
                    senderId: activity.creatorId,
                    senderName: activity.creatorName,
                    content: "好的，我等你，我穿黑色T恤，戴眼鏡。"
                )
                
                withAnimation {
                    messages.append(replyMessage)
                }
            }
        }
    }
}

#Preview {
    MapView()
} 
