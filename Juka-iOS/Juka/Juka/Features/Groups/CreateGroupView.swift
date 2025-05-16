import SwiftUI
import PhotosUI
import MapKit

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage? = nil
    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var title: String = ""
    @State private var activityDescription: String = ""
    @State private var groupType: GroupType = .coffeeDeal
    @State private var expiryHours: Double = 1.0
    @State private var location = Location(latitude: 25.033, longitude: 121.565, placeName: "台北市")
    @State private var showLocationPicker = false
    @State private var isProcessing: Bool = false
    @State private var isGenerating: Bool = false
    @State private var showGroupStatus = false
    @State private var createdActivity: GroupActivity?
    
    // Binding for the presentation state
    @Binding var isPresented: Bool
    
    // Callback for when a group is created
    var onGroupCreated: ((GroupActivity) -> Void)?
    
    // Default initializer for preview and direct use
    init() {
        self._isPresented = .constant(true)
        self.onGroupCreated = nil
    }
    
    // Initializer with binding and callback
    init(isPresented: Binding<Bool>, onGroupCreated: @escaping (GroupActivity) -> Void) {
        self._isPresented = isPresented
        self.onGroupCreated = onGroupCreated
    }
    
    // Helper computed properties to break up complex expressions
    private var aiButtonGradient: LinearGradient {
        LinearGradient(
            colors: [Color.purple, Color.blue],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    private var aiButtonBackground: some View {
        Group {
            if selectedImage == nil {
                Color.gray.opacity(0.3)
            } else {
                aiButtonGradient
            }
        }
    }
    
    private var expiryTimeFormatted: String {
        Date().addingTimeInterval(expiryHours * 3600).formatted(.dateTime)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Header section with type selection and preview image
                Section {
                    VStack(spacing: 20) {
                        // Group Type selector at top
                        HStack {
                            Text("揪團類型")
                                .font(.headline)
                            
                            Spacer()
                            
                            GroupTypePicker(selectedType: $groupType)
                        }
                        
                        Divider()
                        
                        // Image upload area
                        if let image = selectedImage {
                            SelectedImageView(
                                image: image,
                                isProcessing: isProcessing,
                                isGenerating: isGenerating,
                                onRemove: { selectedImage = nil }
                            )
                        } else {
                            ImagePickerButton(
                                selectedImageItem: $selectedImageItem,
                                onSelect: { item in
                                    isProcessing = true
                                    loadTransferable(from: item)
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Description Section
                Section(header: Text("活動資訊")) {
                    TextField("活動標題", text: $title)
                        .font(.title3)
                        .padding(.vertical, 8)
                    
                    DescriptionEditor(text: $activityDescription)
                    
                    // AI generation button
                    Button {
                        simulateAIGeneration()
                    } label: {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .font(.headline)
                            Text("AI智能生成文案")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(aiButtonBackground)
                        .foregroundColor(selectedImage == nil ? .gray : .white)
                        .cornerRadius(10)
                    }
                    .disabled(selectedImage == nil || isGenerating)
                    .padding(.top, 8)
                }
                
                // Location Section
                Section(header: Text("地點")) {
                    LocationButton(
                        location: location,
                        onTap: { showLocationPicker = true }
                    )
                    .sheet(isPresented: $showLocationPicker) {
                        LocationPickerView(selectedLocation: $location)
                    }
                }
                
                // Time Section
                Section(header: Text("有效時間")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("優惠有效時間:")
                                .font(.headline)
                            Text("\(Int(expiryHours)) 小時")
                                .font(.headline)
                                .foregroundColor(AppStyles.primary)
                        }
                        
                        Slider(value: $expiryHours, in: 0.5...24, step: 0.5)
                            .accentColor(AppStyles.primary)
                        
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.secondary)
                            Text("結束時間: \(expiryTimeFormatted)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("建立揪團")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("取消") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("建立") {
                        submitGroup()
                    }
                    .disabled(title.isEmpty || activityDescription.isEmpty)
                    .fontWeight(.semibold)
                    .foregroundColor(title.isEmpty || activityDescription.isEmpty ? .gray : AppStyles.primary)
                }
            }
            .navigationDestination(isPresented: $showGroupStatus) {
                if let activity = createdActivity {
                    GroupStatusView(activity: activity)
                }
            }
        }
    }
    
    private func typeTitle(for type: GroupType) -> String {
        switch type {
        case .coffeeDeal: return "咖啡優惠"
        case .foodDeal: return "美食優惠"
        case .rideShare: return "共乘"
        case .shopping: return "購物優惠"
        case .other: return "其他"
        }
    }
    
    private func loadTransferable(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let imageData):
                    if let data = imageData, let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        simulateOCRProcess()
                    }
                case .failure:
                    print("Failed to load image")
                }
                isProcessing = false
            }
        }
    }
    
    // Simulate OCR processing
    private func simulateOCRProcess() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            // Set mock data for preview
            if groupType == .coffeeDeal {
                title = "星巴克買一送一"
                activityDescription = "星巴克指定飲品買一送一優惠"
            } else if groupType == .foodDeal {
                title = "麥當勞買一送一"
                activityDescription = "麥當勞大麥克買一送一優惠"
            }
        }
    }
    
    // Simulate AI generation
    private func simulateAIGeneration() {
        isGenerating = true
        
        // Simulate delay for AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Generate better copy based on group type
            if groupType == .coffeeDeal {
                title = "星巴克限時買一送一"
                activityDescription = "星巴克指定大杯飲品買一送一，限今日！要不要一起？省一半錢！最低消費200元，每人限購2份。優惠不與其他優惠同享。"
            } else if groupType == .foodDeal {
                title = "麥當勞大麥克優惠"
                activityDescription = "麥當勞大麥克買一送一，快來一起分享美味漢堡！限時特價！此優惠每人限購2份，需出示麥當勞APP優惠券。"
            } else if groupType == .rideShare {
                title = "台北到桃園共乘"
                activityDescription = "今晚8點從台北到桃園，有人要拼車嗎？平分車資，省時又省錢！可搭載4人，出發地點捷運台北車站，目的地桃園高鐵站。"
            }
            
            isGenerating = false
        }
    }
    
    private func submitGroup() {
        // Create group activity
        let newActivity = GroupActivity(
            title: title,
            activityDescription: activityDescription,
            expiresAt: Date().addingTimeInterval(expiryHours * 3600),
            location: location,
            creatorId: "currentUser",
            creatorName: "我", // In a real app, use current user's name
            type: groupType
        )
        
        createdActivity = newActivity
        
        // Dismiss this view first
        isPresented = false
        
        // Call the callback after dismissal
        onGroupCreated?(newActivity)
    }
}

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedLocation: Location
    @State private var searchText = ""
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.033, longitude: 121.565),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        NavigationStack {
            VStack {
                // Map
                Map(coordinateRegion: $region, annotationItems: [selectedLocation]) { location in
                    MapMarker(coordinate: location.coordinate, tint: .red)
                }
                .ignoresSafeArea(edges: .top)
                .frame(height: 300)
                
                // Search
                TextField("搜尋地點", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Sample locations (would be search results in a real app)
                List {
                    Button("台北 101") {
                        selectedLocation = Location(latitude: 25.033, longitude: 121.565, placeName: "台北 101")
                        region.center = selectedLocation.coordinate
                        dismiss()
                    }
                    
                    Button("信義商圈") {
                        selectedLocation = Location(latitude: 25.036, longitude: 121.568, placeName: "信義商圈")
                        region.center = selectedLocation.coordinate
                        dismiss()
                    }
                    
                    Button("象山捷運站") {
                        selectedLocation = Location(latitude: 25.030, longitude: 121.562, placeName: "象山捷運站")
                        region.center = selectedLocation.coordinate
                        dismiss()
                    }
                    
                    Button("市政府") {
                        selectedLocation = Location(latitude: 25.038, longitude: 121.563, placeName: "市政府")
                        region.center = selectedLocation.coordinate
                        dismiss()
                    }
                }
            }
            .navigationTitle("選擇地點")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("確認") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CreateGroupView(isPresented: .constant(true), onGroupCreated: { _ in })
}

// MARK: - Helper Views

struct GroupTypePicker: View {
    @Binding var selectedType: GroupType
    
    var body: some View {
        Picker("", selection: $selectedType) {
            ForEach([GroupType.coffeeDeal, .foodDeal, .rideShare, .shopping, .other], id: \.self) { type in
                HStack {
                    GroupTypeIcon(type: type)
                        .frame(width: 24, height: 24)
                    Text(typeTitle(for: type))
                }
                .tag(type)
            }
        }
        .pickerStyle(.menu)
        .accentColor(AppStyles.primary)
    }
    
    private func typeTitle(for type: GroupType) -> String {
        switch type {
        case .coffeeDeal: return "咖啡優惠"
        case .foodDeal: return "美食優惠"
        case .rideShare: return "共乘"
        case .shopping: return "購物優惠"
        case .other: return "其他"
        }
    }
}

struct SelectedImageView: View {
    let image: UIImage
    let isProcessing: Bool
    let isGenerating: Bool
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            // Show selected image with options
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                
                // Remove image button
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 30, height: 30)
                        )
                        .shadow(radius: 2)
                }
                .padding(8)
            }
            
            // Processing indicators
            if isProcessing {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("OCR 處理中...")
                    Spacer()
                }
                .padding(10)
                .background(AppStyles.primary.opacity(0.1))
                .cornerRadius(8)
            } else if isGenerating {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding(.trailing, 8)
                    Text("AI 生成文案中...")
                    Spacer()
                }
                .padding(10)
                .background(AppStyles.primary.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct ImagePickerButton: View {
    @Binding var selectedImageItem: PhotosPickerItem?
    let onSelect: (PhotosPickerItem) -> Void
    
    var body: some View {
        PhotosPicker(selection: $selectedImageItem, matching: .images) {
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 40))
                    .foregroundColor(AppStyles.primary)
                
                Text("拍攝或上傳優惠圖片")
                    .font(.headline)
                    .foregroundColor(AppStyles.primary)
                
                Text("上傳圖片可以幫助其他用戶更快了解你的揪團")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(imagePlaceholderBackground)
        }
        .onChange(of: selectedImageItem) { _, newValue in
            if let newValue {
                onSelect(newValue)
            }
        }
    }
    
    private var imagePlaceholderBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(AppStyles.primary.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundColor(AppStyles.primary.opacity(0.5))
            )
    }
}

struct DescriptionEditor: View {
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("活動描述")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $text)
                .frame(minHeight: 120)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

struct LocationButton: View {
    let location: Location
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                
                VStack(alignment: .leading) {
                    Text("活動地點")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(location.placeName ?? "選擇地點")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
} 