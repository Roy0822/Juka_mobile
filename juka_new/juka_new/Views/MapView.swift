import SwiftUI
import MapKit

// Define accent colors directly (copied from ContentView)
// let accentColor1 = Color(red: 1.0, green: 107/255, blue: 149/255) // FF6B95
// let accentColor2 = Color(red: 1.0, green: 151/255, blue: 119/255) // FF9777
// let actionGradient = LinearGradient(colors: [accentColor1, accentColor2], startPoint: .topLeading, endPoint: .bottomTrailing)

struct MapView: View {
    // 使用LocationManager
    @StateObject private var locationManager = LocationManager.shared
    
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.033, longitude: 121.565),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
    )
    @State private var showNewGroupSheet = false
    @State private var showGroupDetail: GroupActivity? = nil
    @State private var showJoinSheet = false
    @State private var selectedActivity: GroupActivity? = nil
    @State private var showLocationAlert = false  // 用於顯示位置錯誤提示
    
    // 搜尋和過濾相關狀態
    @State private var searchText = ""
    @State private var selectedCategory = "全部"
    
    // 用來控制鍵盤隱藏的標誌
    @State private var shouldDismissKeyboard = false
    
    // 從JSON讀取模擬數據，替代原本的硬編碼數據
    @State private var activities: [GroupActivity] = []
    
    // 添加加載狀態跟踪
    @State private var isLoading = true
    @State private var lastUpdateTime = Date()
    
    // 計算過濾後的活動
    private var filteredActivities: [GroupActivity] {
        var filtered = activities
        
        // 根據搜尋文字過濾
        if !searchText.isEmpty {
            filtered = filtered.filter { activity in
                activity.title.localizedCaseInsensitiveContains(searchText) ||
                activity.activityDescription.localizedCaseInsensitiveContains(searchText) ||
                (activity.location.placeName ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // 根據類別過濾
        if selectedCategory != "全部" {
            filtered = filtered.filter { activity in
                switch selectedCategory {
                case "咖啡":
                    return activity.type == .coffeeDeal
                case "美食":
                    return activity.type == .foodDeal
                case "共乘":
                    return activity.type == .rideShare
                case "購物":
                    return activity.type == .groceryShopping
                case "娛樂":
                    return activity.type == .textbookExchange
                default:
                    return true
                }
            }
        }
        
        return filtered
    }
    
    var body: some View {
        ZStack {
            // 地圖
            Map(position: $cameraPosition) {
                ForEach(filteredActivities) { activity in
                    let id = activity.id // 捕獲ID以確保唯一性
                    Annotation(activity.title, coordinate: activity.location.coordinate) {
                        MapPin(activity: activity) {
                            print("點擊了地標：\(activity.title)")
                            selectedActivity = activity
                            showGroupDetail = activity
                            
                            // 點擊地圖標記時隱藏鍵盤
                            dismissKeyboard()
                        }
                        .id(id) // 確保每個Pin都有唯一ID
                        .allowsHitTesting(true) // 確保可點擊
                    }
                }
                
                // 如果有用戶位置，顯示藍點
                if locationManager.location != nil {
                    UserAnnotation() 
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea()
            // 移除地圖的點擊手勢，僅保留標記的點擊事件
            
            // 加載指示器
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                ProgressView("載入中...")
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            
            // 搜尋框 and Filter Bar
            VStack {
                MapSearchBar(searchText: $searchText, shouldDismissKeyboard: $shouldDismissKeyboard)
                    .padding(.horizontal)
                    .padding(.top) // Adjust top padding

                MapFilterBar(selectedCategory: $selectedCategory) // Moved here
                    .padding(.horizontal)
                    .padding(.bottom, 8) // Add some bottom padding
                
                // 如果沒有結果，顯示提示
                if filteredActivities.isEmpty && (!searchText.isEmpty || selectedCategory != "全部") {
                    Text("沒有找到符合條件的活動")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.7))
                        )
                        .padding(.top, 10)
                }
                
                Spacer()
            }
            
            // 按鈕層 - 位置和創建
            VStack {
                Spacer()
                
                HStack {
                    // 左下角 - 顯示「我的位置」按鈕
                    Button(action: getUserLocation) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 50, height: 50)
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                            
                            Image(systemName: "location.fill")
                                .font(.system(size: 20))
                                .foregroundColor(accentColor1)
                        }
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // 右下角 - 創建揪團按鈕
                    Button(action: {
                        // 收起鍵盤並顯示新建表單
                        dismissKeyboard()
                        showNewGroupSheet = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(actionGradient)
                                .frame(width: 60, height: 60)
                                .shadow(color: accentColor1.opacity(0.3), radius: 15, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.bottom, 150)
            }
        }
        .onAppear {
            loadData()
            
            // 請求位置權限
            locationManager.requestLocationPermission()
            
            // 添加對隱藏鍵盤通知的監聽
            setupKeyboardDismissNotification()
        }
        .onDisappear {
            // 移除通知監聽
            NotificationCenter.default.removeObserver(NotificationCenter.self, name: .dismissKeyboard, object: nil)
        }
        // 減少位置更新頻率，只在顯著變化時更新
        .onReceive(locationManager.$region.throttle(for: 2, scheduler: RunLoop.main, latest: true)) { newRegion in
            // 僅在用戶請求位置時更新地圖位置
            if Date().timeIntervalSince(lastUpdateTime) > 5 {
                cameraPosition = .region(newRegion)
            }
        }
        .sheet(item: $showGroupDetail) { activity in
            ActivityDetailSheet(activity: activity) {
                showGroupDetail = nil
                selectedActivity = activity
                showJoinSheet = true
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showJoinSheet, onDismiss: {
            selectedActivity = nil
        }) {
            if let activity = selectedActivity {
                JoinGroupView(activity: activity, isJoined: { 
                    print("成功加入揪團：\(activity.title)")
                })
            }
        }
        .sheet(isPresented: $showNewGroupSheet) {
            CreateGroupSheet { newActivity in
                print("創建了新揪團：\(newActivity.title)")
            }
        }
        .alert("無法獲取位置", isPresented: $showLocationAlert) {
            Button("去設定", role: .none) {
                // 打開設定頁面
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("請在設定中允許「揪咖」使用您的位置，以便顯示附近的揪團活動")
        }
    }
    
    // 優化數據加載方法
    private func loadData() {
        isLoading = true
        
        // 在背景線程加載數據
        DispatchQueue.global(qos: .userInitiated).async {
            let loadedActivities = MockDataLoader.shared.loadMockActivities()
            
            // 回到主線程更新UI
            DispatchQueue.main.async {
                activities = loadedActivities
                isLoading = false
                lastUpdateTime = Date()
            }
        }
    }
    
    // 設置通知監聽
    private func setupKeyboardDismissNotification() {
        NotificationCenter.default.addObserver(
            forName: .dismissKeyboard,
            object: nil,
            queue: .main
        ) { _ in
            dismissKeyboard()
        }
    }
    
    // 收起鍵盤的方法
    private func dismissKeyboard() {
        shouldDismissKeyboard = true
        // 立即重置標誌，以便下次可以再次觸發
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            shouldDismissKeyboard = false
        }
    }
    
    // 獲取用戶位置並移動地圖
    private func getUserLocation() {
        print("點擊了定位按鈕")
        
        // 收起鍵盤
        dismissKeyboard()
        
        // 更新時間戳以允許地圖更新
        lastUpdateTime = Date()
        
        // 強制請求一次位置權限
        locationManager.requestLocationPermission()
        
        // 嘗試獲取當前位置
        locationManager.getCurrentLocation()
        
        // 如果已經有位置信息，直接移動地圖
        if let location = locationManager.location {
            print("使用現有位置: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            
            // 使用非動畫方式更新相機位置
            withAnimation(.none) {
                cameraPosition = .region(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }
        }
    }
}

struct MapSearchBar: View {
    @Binding var searchText: String
    @Binding var shouldDismissKeyboard: Bool
    
    // 內部使用的FocusState
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            
            TextField("搜尋位置或活動", text: $searchText)
                .padding(10)
                .foregroundColor(Color.primary) // Standard text color
                .autocorrectionDisabled(true)
                .submitLabel(.search)
                .focused($isInputActive) // 連接內部FocusState
                .onSubmit {
                    // 提交搜尋時收起鍵盤
                    isInputActive = false
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground)) // Standard background
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .frame(height: 50)
        .onChange(of: shouldDismissKeyboard) { oldValue, newValue in
            // 當父視圖要求收起鍵盤時
            if newValue {
                isInputActive = false
            }
        }
    }
}

struct MapFilterBar: View {
    let categories = ["全部", "咖啡", "美食", "共乘", "購物", "娛樂"]
    @Binding var selectedCategory: String
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(categories, id: \.self) { category in
                    FilterButton(
                        title: category, 
                        isSelected: selectedCategory == category,
                        action: { 
                            withAnimation {
                                selectedCategory = category
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 12) // Add horizontal padding inside the HStack
            .padding(.vertical, 8) // Reduce vertical padding to decrease height
        }
        // Constrain the height of the ScrollView
        .frame(height: 44) // Adjust height as needed
        .background(
            RoundedRectangle(cornerRadius: 22) // Adjust corner radius if needed
                .fill(Color(.secondarySystemBackground)) // Standard secondary bg
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1) // Standard stroke
                )
                .shadow(color: .gray.opacity(0.1), radius: 5, x:0, y:2) // Optional shadow
        )
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    // REMOVED themeManager
    // @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .foregroundColor(isSelected ? .white : .gray) // Keep selected white
                .background(
                    isSelected ?
                    RoundedRectangle(cornerRadius: 16)
                        .fill(actionGradient) // Use defined gradient
                        .shadow(color: accentColor1.opacity(0.2), radius: 3, x: 0, y: 1)
                         : nil
                )
        }
    }
}

struct MapPin: View {
    let activity: GroupActivity
    let action: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(actionGradient)
                    .frame(width: isHovering ? 50 : 40, height: isHovering ? 50 : 40)
                    .shadow(color: accentColor1.opacity(0.3), radius: 5, x: 0, y: 2)
                
                Image(systemName: activity.type.icon)
                    .font(.system(size: isHovering ? 24 : 20))
                    .foregroundColor(.white)
            }
            
            Image(systemName: "triangle.fill")
                .font(.system(size: 12))
                .foregroundColor(accentColor1)
                .rotationEffect(.degrees(180))
                .offset(y: -5)
        }
        .onTapGesture {
            print("標記內部點擊: \(activity.title)") // 添加調試信息
            isHovering = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isHovering = false }
            
            // 使用主線程延遲調用以確保UI更新後再執行動作
            DispatchQueue.main.async {
                action()
            }
        }
        .scaleEffect(isHovering ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isHovering)
        .contentShape(Rectangle()) // 增加可點擊區域
        .frame(width: 50, height: 55) // 確保有足夠的點擊區域
    }
}

struct ActivityDetailSheet: View {
    let activity: GroupActivity
    let onJoin: () -> Void
    // REMOVED themeManager
    // @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text(activity.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color.primary) // Standard primary
                    
                    Text(activity.location.placeName ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondary) // Use Color.secondary instead of .secondaryLabel
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(.secondarySystemBackground)) // Standard secondary bg
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: activity.type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(accentColor1) // Use defined accent
                }
            }
            
            Text(activity.activityDescription)
                .font(.system(size: 16))
                .foregroundColor(Color.primary.opacity(0.9))
                .padding(.vertical, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                DetailRow(
                    icon: "person.fill",
                    text: "發起人: \(activity.creatorName)"
                )
                
                if let expiresAt = activity.expiresAt {
                    DetailRow(
                        icon: "clock.fill",
                        text: "有效期限至: \(formatDate(expiresAt))"
                    )
                }
                
                DetailRow(
                    icon: "person.2.fill",
                    text: "參與人數: \(activity.participantIds.count + 1) 人"
                )
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            Button(action: onJoin) {
                HStack {
                    Image(systemName: "person.badge.plus")
                    Text("加入揪團")
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(actionGradient) // Use defined gradient
                .cornerRadius(16)
                .shadow(color: accentColor1.opacity(0.3), radius: 5, x: 0, y: 3)
            }
        }
        .padding()
        .background(
            LinearGradient(
                // Standard light backgrounds
                colors: [Color(.secondarySystemBackground), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct DetailRow: View {
    let icon: String
    let text: String
    // REMOVED themeManager
    // @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(accentColor1) // Use defined accent
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color.primary.opacity(0.8))
        }
    }
}

#Preview {
    MapView()
        // REMOVED environmentObject
        // .environmentObject(ThemeManager.shared)
} 