import SwiftUI
import MapKit
import PhotosUI

struct CreateGroupSheet: View {
    let onCreateGroup: (GroupActivity) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var groupType: GroupType = .coffeeDeal
    @State private var orderTimeType: OrderTimeType = .immediate
    @State private var expiryHours = 1.0
    @State private var scheduledDate = Date().addingTimeInterval(3600)
    @State private var scheduledEndDate = Date().addingTimeInterval(7200)
    @State private var selectedImage: UIImage?
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var isProcessing = false
    @State private var isGenerating = false
    @State private var showLocationPicker = false
    @State private var selectedLocation: CLLocationCoordinate2D?
    @State private var placeName: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        ZStack {
                            if let selectedImage = selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                    .overlay(
                                        Button(action: {
                                            self.selectedImage = nil
                                            self.selectedImageItem = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title)
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.black.opacity(0.5)))
                                        }
                                        .padding(8),
                                        alignment: .topTrailing
                                    )
                            } else {
                                PhotosPicker(selection: $selectedImageItem, matching: .images) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(accentColor1)
                                        
                                        Text("上傳優惠圖片")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.primary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 160)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color(.secondarySystemBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                            )
                                            .shadow(color: .gray.opacity(0.08), radius: 4, x:0, y:1)
                                    )
                                }
                            }
                            
                            if isProcessing {
                                Rectangle()
                                    .fill(Color.black.opacity(0.5))
                                    .cornerRadius(20)
                                    .frame(height: 160)
                                
                                ProgressView("處理圖片中...")
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .foregroundColor(.white)
                            }
                        }
                        .onChange(of: selectedImageItem) { _, newValue in
                            if let newValue {
                                isProcessing = true
                                loadTransferable(from: newValue)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("優惠類型")
                                .font(.system(size: 16))
                                .foregroundColor(Color.primary)
                            
                            HStack {
                                ForEach(GroupType.allCases, id: \.self) { type in
                                    GroupTypeButton(
                                        type: type,
                                        isSelected: groupType == type,
                                        action: { groupType = type }
                                    )
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            InputField(
                                title: "活動標題",
                                text: $title,
                                placeholder: "輸入標題"
                            )
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("活動描述")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.primary)
                                
                                ZStack(alignment: .topLeading) {
                                    TextEditor(text: $description)
                                        .padding(8)
                                        .frame(height: 100)
                                        .foregroundColor(Color.primary)
                                        .scrollContentBackground(.hidden)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.secondarySystemBackground))
                                        )
                                    
                                    if description.isEmpty {
                                        Text("輸入活動描述...")
                                            .foregroundColor(Color.secondary)
                                            .padding(16)
                                            .allowsHitTesting(false)
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("活動地點")
                                .font(.system(size: 16))
                                .foregroundColor(Color.primary)
                            
                            Button(action: {
                                showLocationPicker = true
                            }) {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(accentColor1)
                                        .padding(.leading, 10)
                                    
                                    Text(placeName ?? "選擇位置")
                                        .foregroundColor(placeName == nil ? Color.secondary : Color.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color.secondary)
                                }
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.secondarySystemBackground))
                                )
                            }
                        }
                        
                        // 訂單時間類型選擇
                        VStack(alignment: .leading, spacing: 12) {
                            Text("訂單時間類型")
                                .font(.system(size: 16))
                                .foregroundColor(Color.primary)
                                
                            HStack(spacing: 12) {
                                Button(action: {
                                    orderTimeType = .immediate
                                }) {
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(orderTimeType == .immediate ? accentColor1 : Color.gray.opacity(0.5))
                                            )
                                        
                                        Text("立即訂單")
                                            .foregroundColor(orderTimeType == .immediate ? accentColor1 : Color.primary)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(orderTimeType == .immediate ? accentColor1.opacity(0.1) : Color(.secondarySystemBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(orderTimeType == .immediate ? accentColor1 : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                                
                                Button(action: {
                                    orderTimeType = .scheduled
                                }) {
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .fill(orderTimeType == .scheduled ? accentColor1 : Color.gray.opacity(0.5))
                                            )
                                        
                                        Text("預約訂單")
                                            .foregroundColor(orderTimeType == .scheduled ? accentColor1 : Color.primary)
                                            .font(.system(size: 14))
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(orderTimeType == .scheduled ? accentColor1.opacity(0.1) : Color(.secondarySystemBackground))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(orderTimeType == .scheduled ? accentColor1 : Color.clear, lineWidth: 1)
                                            )
                                    )
                                }
                            }
                        }
                        
                        // 根據訂單類型顯示不同的時間選擇
                        if orderTimeType == .immediate {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("有效時間: \(Int(expiryHours)) 小時")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.primary)
                                
                                Slider(value: $expiryHours, in: 0.5...24, step: 0.5)
                                    .accentColor(accentColor1)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("開始時間")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.primary)
                                    
                                    DatePicker("", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .accentColor(accentColor1)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.secondarySystemBackground))
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("結束時間")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.primary)
                                    
                                    DatePicker("", selection: $scheduledEndDate, in: scheduledDate..., displayedComponents: [.date, .hourAndMinute])
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .accentColor(accentColor1)
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color(.secondarySystemBackground))
                                        )
                                }
                            }
                        }
                        
                        Button(action: {
                            generateAIContent()
                        }) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(accentColor1)
                                
                                Text(isGenerating ? "生成中..." : "AI生成文案")
                                    .foregroundColor(accentColor1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(accentColor1.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(accentColor1, lineWidth: 1)
                                    )
                            )
                        }
                        .disabled(selectedImage == nil || isGenerating)
                        .opacity(selectedImage == nil || isGenerating ? 0.5 : 1)
                        
                        Button(action: {
                            createGroup()
                        }) {
                            Text("創建揪團")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(actionGradient)
                                .cornerRadius(16)
                                .shadow(
                                    color: accentColor1.opacity(0.3),
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                        }
                        .disabled(title.isEmpty || description.isEmpty || selectedLocation == nil)
                        .opacity(title.isEmpty || description.isEmpty || selectedLocation == nil ? 0.5 : 1)
                    }
                    .padding()
                }
            }
            .navigationTitle("建立揪團")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(accentColor1)
                }
            }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView(
                    selectedLocation: $selectedLocation,
                    placeName: $placeName
                )
                .presentationDetents([.medium, .large])
            }
        }
    }
    
    private func loadTransferable(from item: PhotosPickerItem) {
        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
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
    
    private func simulateOCRProcess() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // 根據選擇的類型自動填充示例數據
            if self.groupType == .coffeeDeal {
                self.title = "星巴克買一送一"
                self.description = "星巴克指定飲品買一送一優惠"
            } else if self.groupType == .foodDeal {
                self.title = "麥當勞買一送一"
                self.description = "麥當勞大麥克買一送一優惠"
            }
        }
    }
    
    // 模擬AI生成
    private func generateAIContent() {
        isGenerating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 依據類型生成更好的文案
            if self.groupType == .coffeeDeal {
                self.title = "星巴克限時買一送一"
                self.description = "星巴克指定大杯飲品買一送一，限今日！要不要一起？省一半錢！"
            } else if self.groupType == .foodDeal {
                self.title = "麥當勞大麥克優惠"
                self.description = "麥當勞大麥克買一送一，快來一起分享美味漢堡！限時特價！"
            } else if self.groupType == .rideShare {
                self.title = "台北到桃園共乘"
                self.description = "今晚8點從台北到桃園，有人要拼車嗎？平分車資，省時又省錢！"
            }
            
            self.isGenerating = false
        }
    }
    
    private func createGroup() {
        guard let coord = selectedLocation else { return }
        
        // 創建位置
        let location = Location(
            latitude: coord.latitude,
            longitude: coord.longitude,
            placeName: placeName,
            address: placeName
        )
        
        var expiresAt: Date?
        var scheduledEndTime: Date?
        
        // 根據訂單類型設定時間
        if orderTimeType == .immediate {
            // 立即訂單：設定倒數結束時間
            expiresAt = Date().addingTimeInterval(expiryHours * 3600)
            scheduledEndTime = nil
        } else {
            // 預約訂單：設定開始和結束時間
            expiresAt = scheduledDate
            scheduledEndTime = scheduledEndDate
        }
        
        // 創建群組活動
        let newActivity = GroupActivity(
            title: title,
            activityDescription: description,
            orderTimeType: orderTimeType,
            expiresAt: expiresAt,
            scheduledEndTime: scheduledEndTime,
            location: location,
            creatorId: "currentUser",
            creatorName: "我", // 在實際應用中，使用當前用戶的名稱
            type: groupType
        )
        
        onCreateGroup(newActivity)
        dismiss()
    }
}

struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color.primary)
            
            TextField(placeholder, text: $text)
                .padding()
                .foregroundColor(Color.primary)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
                .placeholder(when: text.isEmpty) {
                    Text(placeholder).foregroundColor(Color.secondary)
                }
        }
    }
}

struct GroupTypeButton: View {
    let type: GroupType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor1 : Color(.secondarySystemBackground))
                        .frame(width: 50, height: 50)
                        .shadow(color: .gray.opacity(isSelected ? 0.15 : 0.08), radius: 3, x: 0, y: 1)
                    
                    Image(systemName: type.icon)
                        .foregroundColor(isSelected ? .white : Color.primary)
                }
                
                Text(type.displayName)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? accentColor1 : Color.secondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct LocationPickerView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var placeName: String?
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var region: MKCoordinateRegion
    @State private var cameraPosition: MapCameraPosition
    @State private var isSearching = false
    @State private var dragLocation: CLLocationCoordinate2D?
    @State private var isDragging = false
    
    // 位置管理器
    @StateObject private var locationManager = LocationManager.shared
    
    init(selectedLocation: Binding<CLLocationCoordinate2D?>, placeName: Binding<String?>) {
        self._selectedLocation = selectedLocation
        self._placeName = placeName
        
        // 默認使用台北市中心
        let defaultRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 25.033, longitude: 121.565),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        self._region = State(initialValue: defaultRegion)
        self._cameraPosition = State(initialValue: .region(defaultRegion))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 搜尋欄
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        
                        TextField("搜尋位置", text: $searchText, onCommit: {
                            performSearch()
                        })
                        .padding(10)
                        .foregroundColor(Color.primary)
                        .submitLabel(.search)
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                    .padding()
                    
                    // 搜尋結果列表
                    if isSearching {
                        ProgressView("搜尋中...")
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.primary))
                            .foregroundColor(Color.primary)
                            .padding()
                    } else if !searchResults.isEmpty {
                        List {
                            ForEach(searchResults, id: \.self) { item in
                                Button(action: {
                                    selectLocation(item)
                                }) {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(accentColor1)
                                        
                                        VStack(alignment: .leading) {
                                            Text(item.name ?? "未知位置")
                                                .foregroundColor(Color.primary)
                                            
                                            if let address = item.placemark.title {
                                                Text(address)
                                                    .font(.caption)
                                                    .foregroundColor(Color.secondary)
                                            }
                                        }
                                    }
                                }
                                .listRowBackground(Color(.secondarySystemBackground))
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .background(Color(.systemBackground))
                    } else {
                        // 地圖視圖
                        ZStack {
                            Map(position: $cameraPosition, interactionModes: .all) {
                                if let location = isDragging ? dragLocation : selectedLocation {
                                    Marker("", coordinate: location)
                                        .tint(accentColor1)
                                }
                            }
                            .mapStyle(.standard)
                            
                            // 中心固定的圖釘標記 - 只在拖動時顯示
                            if isDragging {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(accentColor1)
                                    .background(
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 25, height: 25)
                                    )
                                
                                // 底部陰影
                                Image(systemName: "mappin")
                                    .font(.caption)
                                    .foregroundColor(accentColor1.opacity(0.6))
                                    .offset(y: 12)
                            }
                        }
                        .overlay(
                            Text(isDragging ? "移動地圖來選擇位置" : "按住地圖可拖動位置")
                                .font(.caption)
                                .padding(6)
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(5)
                                .padding(),
                            alignment: .bottom
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    // 拖動開始或繼續
                                    isDragging = true
                                    
                                    // 獲取當前地圖中心點的坐標
                                    if let region = cameraPosition.region {
                                        dragLocation = region.center
                                    }
                                }
                                .onEnded { _ in
                                    // 拖動結束
                                    isDragging = false
                                    
                                    // 確認位置
                                    if let location = dragLocation {
                                        selectedLocation = location
                                        lookupPlaceName(for: location)
                                    }
                                }
                        )
                        
                        // 用戶位置按鈕
                        VStack {
                            Spacer()
                            
                            HStack {
                                Spacer()
                                
                                Button(action: goToUserLocation) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 40, height: 40)
                                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 1)
                                        
                                        Image(systemName: "location.fill")
                                            .foregroundColor(accentColor1)
                                    }
                                }
                                .padding(.trailing, 16)
                                .padding(.bottom, 16)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // 確認按鈕
                    Button(action: {
                        dismiss()
                    }) {
                        Text("確認位置")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(actionGradient)
                            .cornerRadius(16)
                            .shadow(
                                color: accentColor1.opacity(0.3),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    }
                    .padding()
                    .disabled(selectedLocation == nil)
                    .opacity(selectedLocation == nil ? 0.5 : 1)
                }
            }
            .navigationTitle("選擇位置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button("關閉") {
                         dismiss()
                     }
                     .foregroundColor(accentColor1)
                 }
            }
            .onAppear {
                // 首次顯示視圖時，嘗試使用當前位置
                goToUserLocation()
            }
        }
    }
    
    private func performSearch() {
        isSearching = true
        searchResults = []
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            isSearching = false
            
            guard let response = response, error == nil else {
                return
            }
            
            searchResults = response.mapItems
        }
    }
    
    private func selectLocation(_ item: MKMapItem) {
        selectedLocation = item.placemark.coordinate
        placeName = item.name
        
        // 更新地圖區域和相機位置
        let newRegion = MKCoordinateRegion(
            center: item.placemark.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        region = newRegion
        cameraPosition = .region(newRegion)
        
        // 清空搜尋結果
        searchResults = []
        searchText = ""
    }
    
    // 移動到用戶當前位置
    private func goToUserLocation() {
        // 請求位置權限
        locationManager.requestLocationPermission()
        
        // 嘗試獲取當前位置
        locationManager.getCurrentLocation()
        
        if let userLocation = locationManager.location?.coordinate {
            print("使用當前位置: \(userLocation.latitude), \(userLocation.longitude)")
            
            // 更新選取的位置
            selectedLocation = userLocation
            
            // 更新地圖區域
            let newRegion = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            
            withAnimation {
                region = newRegion
                cameraPosition = .region(newRegion)
            }
            
            // 獲取位置名稱
            lookupPlaceName(for: userLocation)
        }
    }
    
    private func lookupPlaceName(for coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first, error == nil else {
                placeName = "未知位置"
                return
            }
            
            var name = ""
            
            if let thoroughfare = placemark.thoroughfare {
                name += thoroughfare
            }
            
            if let subThoroughfare = placemark.subThoroughfare {
                name += " " + subThoroughfare
            }
            
            if name.isEmpty {
                if let locality = placemark.locality {
                    name = locality
                } else if let placeName = placemark.name {
                    name = placeName
                } else {
                    name = "未知位置"
                }
            }
            
            placeName = name
        }
    }
}

#Preview {
    CreateGroupSheet { _ in }
}

// Helper for placeholder color (Moved here from ContentView)
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
} 