import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentUser = User(
        id: "currentUser",
        name: "使用者",
        joinedDate: Date(),
        preferences: [.coffeeDeal, .foodDeal]
    )
    @State private var myActivities: [GroupActivity] = []
    @State private var joinedActivities: [GroupActivity] = []
    @State private var selectedTab = 0
    @State private var showEditProfile = false
    @State private var showSettings = false
    @State private var showGroupStatus = false
    @State private var selectedActivity: GroupActivity?
    
    // For editing profile
    @State private var editedName = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    
    private let tabs = ["我發起的", "我參與的"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient for the entire view
                Rectangle()
                    .fill(AppStyles.primaryGradient.opacity(0.15))
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Profile header with image, name and stats
                        profileHeaderSection
                        
                        // Interest preferences card
                        interestPreferencesCard
                            .padding(.horizontal)
                            .padding(.top, 16)
                        
                        // Tab selector
                        tabSelectionView
                            .padding(.top, 16)
                        
                        // Content based on selected tab
                        tabContent
                            .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("個人資料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                            .foregroundColor(AppStyles.primary)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                editProfileView
            }
            .sheet(isPresented: $showSettings) {
                settingsView
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $showGroupStatus) {
                if let activity = selectedActivity {
                    GroupStatusView(activity: activity)
                }
            }
            .onAppear {
                loadSampleData()
                editedName = currentUser.name
            }
        }
    }
    
    // MARK: - Header Section
    
    private var profileHeaderSection: some View {
        VStack(spacing: 24) {
            // Profile image with edit button
            ZStack(alignment: .bottomTrailing) {
                if let profileImage = selectedImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                } else if let imageURL = authManager.currentUser?.profileImageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 3))
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    } placeholder: {
                        profilePlaceholder
                    }
                } else {
                    profilePlaceholder
                }
                
                Button {
                    showImagePicker = true
                } label: {
                    Circle()
                        .fill(AppStyles.primaryGradient)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        )
                        .shadow(color: AppStyles.primary.opacity(0.5), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.top, 16)
            
            // User name with edit button
            HStack {
                Text(currentUser.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Button {
                    showEditProfile = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundColor(AppStyles.primary)
                        .font(.headline)
                }
            }
            
            // Rating stars
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Image(systemName: index < Int(currentUser.rating) ? "star.fill" : "star")
                        .foregroundColor(index < Int(currentUser.rating) ? .yellow : .gray)
                        .font(.callout)
                }
                
                Text("\(String(format: "%.1f", currentUser.rating))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
            }
            
            // Stats section
            HStack(spacing: 0) {
                Spacer()
                
                statItem(count: "\(myActivities.count)", title: "發起")
                
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal)
                
                statItem(count: "\(joinedActivities.count)", title: "參與")
                
                Divider()
                    .frame(height: 40)
                    .padding(.horizontal)
                
                statItem(count: currentUser.joinedDate.formatted(.dateTime.month().year()), title: "加入")
                
                Spacer()
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Interest Preferences
    
    private var interestPreferencesCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("偏好揪團類型")
                    .font(.headline)
                    .foregroundColor(AppStyles.primary)
                
                Spacer()
            }
            
            if currentUser.preferences.isEmpty {
                Text("尚未選擇偏好類型")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(currentUser.preferences, id: \.self) { type in
                        HStack(spacing: 6) {
                            Image(systemName: typeIcon(for: type))
                                .font(.system(size: 12))
                            
                            Text(typeName(for: type))
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(typeGradient(for: type))
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(colorScheme == .dark ? 
                      Color(.systemGray6).opacity(0.8) : 
                      Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        )
    }
    
    // MARK: - Tab Selection
    
    private var tabSelectionView: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button {
                    withAnimation {
                        selectedTab = index
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tabs[index])
                            .font(.subheadline)
                            .fontWeight(selectedTab == index ? .bold : .regular)
                            .foregroundColor(selectedTab == index ? AppStyles.primary : .gray)
                        
                        if selectedTab == index {
                            Rectangle()
                                .fill(AppStyles.primaryGradient)
                                .frame(height: 3)
                                .cornerRadius(1.5)
                        } else {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(height: 3)
                                .cornerRadius(1.5)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Tab Content
    
    private var tabContent: some View {
        VStack {
            switch selectedTab {
            case 0:
                createdActivitiesSection
            case 1:
                joinedActivitiesSection
            default:
                EmptyView()
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Activities Lists
    
    private var createdActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if myActivities.isEmpty {
                emptyStateView(title: "還沒有發起過揪團", message: "點擊右下角的「+」開始揪團")
            } else {
                ForEach(myActivities) { activity in
                    GroupActivityCard(activity: activity, distance: 0) {
                        selectedActivity = activity
                        showGroupStatus = true
                    }
                    .padding(.bottom, 6)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var joinedActivitiesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if joinedActivities.isEmpty {
                emptyStateView(title: "還沒有參與過揪團", message: "在地圖上找到你有興趣的揪團並參與")
            } else {
                ForEach(joinedActivities) { activity in
                    GroupActivityCard(activity: activity, distance: 0) {
                        selectedActivity = activity
                        showGroupStatus = true
                    }
                    .padding(.bottom, 6)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    private var profilePlaceholder: some View {
        Circle()
            .fill(AppStyles.primaryGradient)
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "person.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 40))
            )
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private func statItem(count: String, title: String) -> some View {
        VStack(spacing: 4) {
            Text(count)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
    }
    
    private func emptyStateView(title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "mappin.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
    }
    
    // MARK: - Settings View
    
    private var settingsView: some View {
        NavigationStack {
            List {
                // Notification preferences
                Section(header: Text("通知設定")) {
                    toggleSetting(title: "揪團邀請", isOn: true)
                    toggleSetting(title: "附近揪團提醒", isOn: true)
                    toggleSetting(title: "聊天訊息", isOn: true)
                }
                
                // Privacy settings
                Section(header: Text("隱私設定")) {
                    toggleSetting(title: "顯示個人資料", isOn: true)
                    toggleSetting(title: "允許加入揪團", isOn: true)
                    toggleSetting(title: "分享我的位置", isOn: true)
                }
                
                Section(header: Text("應用程式")) {
                    // App language
                    Picker("語言", selection: .constant("繁體中文")) {
                        Text("繁體中文").tag("繁體中文")
                        Text("English").tag("English")
                        Text("日本語").tag("日本語")
                    }
                    
                    // Tutorial option
                    Button(action: {
                        showSettings = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            authManager.showTutorialAgain()
                        }
                    }) {
                        Label("教學", systemImage: "questionmark.circle")
                            .foregroundColor(.primary)
                    }
                    
                    // Theme selection
                    Picker("主題", selection: $themeManager.selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.displayName, systemImage: theme.icon).tag(theme)
                        }
                    }
                    
                    // Dark mode
                    Picker("深色模式", selection: .constant(0)) {
                        Text("自動").tag(0)
                        Text("淺色").tag(1)
                        Text("深色").tag(2)
                    }
                }
                
                Section(header: Text("關於")) {
                    Button {
                        // Rate app
                    } label: {
                        Label("評分應用程式", systemImage: "star.fill")
                    }
                    
                    Button {
                        // Share app
                    } label: {
                        Label("分享應用程式", systemImage: "square.and.arrow.up")
                    }
                    
                    NavigationLink(destination: Text("常見問題頁面")) {
                        Label("常見問題", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: Text("隱私政策頁面")) {
                        Label("隱私政策", systemImage: "hand.raised")
                    }
                    
                    NavigationLink(destination: Text("服務條款頁面")) {
                        Label("服務條款", systemImage: "doc.text")
                    }
                }
                
                Section {
                    Button {
                        // Feedback
                    } label: {
                        Label("意見回饋", systemImage: "envelope")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack {
                            Spacer()
                            Text("登出")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Text("揪咖 v1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        showSettings = false
                    }
                }
            }
        }
    }
    
    // MARK: - Edit Profile View
    
    private var editProfileView: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("名稱", text: $editedName)
                        .autocapitalization(.none)
                    
                    // Add more fields like bio, contact info, etc.
                } header: {
                    Text("個人資料")
                }
                
                Section {
                    ForEach(GroupType.allCases, id: \.self) { type in
                        Button {
                            togglePreference(type)
                        } label: {
                            HStack {
                                Image(systemName: typeIcon(for: type))
                                    .foregroundColor(typeColor(for: type))
                                    .frame(width: 24, height: 24)
                                
                                Text(typeName(for: type))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if currentUser.preferences.contains(type) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppStyles.primary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("偏好揪團類型")
                } footer: {
                    Text("系統會優先推薦符合你偏好的揪團")
                }
                
                Section {
                    Button {
                        // Save changes
                        currentUser.name = editedName
                        showEditProfile = false
                    } label: {
                        Text("儲存變更")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(AppStyles.primary)
                    }
                }
            }
            .navigationTitle("編輯個人資料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        // Save changes
                        currentUser.name = editedName
                        showEditProfile = false
                    }
                    .foregroundColor(AppStyles.primary)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        editedName = currentUser.name
                        showEditProfile = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func typeIcon(for type: GroupType) -> String {
        switch type {
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
    
    private func typeName(for type: GroupType) -> String {
        switch type {
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
    
    private func typeColor(for type: GroupType) -> Color {
        switch type {
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
    
    private func typeGradient(for type: GroupType) -> LinearGradient {
        let color = typeColor(for: type)
        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private func toggleSetting(title: String, isOn: Bool) -> some View {
        Toggle(isOn: .constant(isOn)) {
            Text(title)
                .font(.subheadline)
        }
        .toggleStyle(SwitchToggleStyle(tint: AppStyles.primary))
    }
    
    private func togglePreference(_ type: GroupType) {
        if currentUser.preferences.contains(type) {
            currentUser.preferences.removeAll(where: { $0 == type })
        } else {
            currentUser.preferences.append(type)
        }
    }
    
    private func loadSampleData() {
        // Sample data for my activities
        let location1 = Location(latitude: 25.033, longitude: 121.565, placeName: "台北 101")
        let location2 = Location(latitude: 25.030, longitude: 121.562, placeName: "象山捷運站")
        
        let myActivity1 = GroupActivity(
            title: "星巴克買一送一",
            activityDescription: "大杯拿鐵買一送一，找人一起享用！",
            expiresAt: Date().addingTimeInterval(3600),
            location: location1,
            creatorId: "currentUser",
            creatorName: currentUser.name,
            participantIds: ["user1", "user2"],
            type: .coffeeDeal
        )
        
        let myActivity2 = GroupActivity(
            title: "共乘去陽明山",
            activityDescription: "週末去陽明山郊遊，有 3 個空位，平分油錢",
            expiresAt: Date().addingTimeInterval(86400),
            location: location2,
            creatorId: "currentUser",
            creatorName: currentUser.name,
            participantIds: ["user3"],
            type: .rideShare
        )
        
        // Sample data for joined activities
        let joined1 = GroupActivity(
            title: "鼎泰豐午餐團",
            activityDescription: "中午去鼎泰豐吃飯，湊滿5人有優惠！",
            expiresAt: Date().addingTimeInterval(7200),
            location: Location(latitude: 25.036, longitude: 121.568, placeName: "信義商圈"),
            creatorId: "user2",
            creatorName: "林小美",
            participantIds: ["currentUser", "user3", "user4"],
            type: .foodDeal
        )
        
        myActivities = [myActivity1, myActivity2]
        joinedActivities = [joined1]
    }
}

// Helper struct for image selection
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// FlowLayout for wrapping tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        
        for row in rows {
            if let last = row.last {
                let lastSize = last.sizeThatFits(.unspecified)
                height += lastSize.height
            }
            
            if row != rows.last {
                height += spacing
            }
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = arrangeSubviews(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        
        for row in rows {
            var x = bounds.minX
            
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
                x += size.width + spacing
            }
            
            if let last = row.last {
                let lastSize = last.sizeThatFits(.unspecified)
                y += lastSize.height + spacing
            }
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        let width = proposal.width ?? 0
        var currentX = 0.0
        var currentRow = 0
        var rows: [[LayoutSubviews.Element]] = [[]]
        
        for subview in subviews {
            let viewSize = subview.sizeThatFits(.unspecified)
            
            if currentX + viewSize.width > width && currentX > 0 {
                currentRow += 1
                currentX = 0
                rows.append([])
            }
            
            rows[currentRow].append(subview)
            currentX += viewSize.width + spacing
        }
        
        return rows
    }
}

extension GroupType: CaseIterable {
    public static var allCases: [GroupType] {
        return [.coffeeDeal, .foodDeal, .rideShare, .shopping, .other]
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AuthenticationManager.shared)
            .environmentObject(ThemeManager.shared)
    }
} 