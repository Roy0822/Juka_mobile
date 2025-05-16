import SwiftUI
import PhotosUI

struct CreateGroupDialog: View {
    @Binding var isPresented: Bool
    @State private var selectedImage: UIImage?
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var title: String = ""
    @State private var activityDescription: String = ""
    @State private var groupType: GroupType = .coffeeDeal
    @State private var expiryHours: Double = 1.0
    @State private var isProcessing: Bool = false
    @State private var isGenerating: Bool = false
    let onSubmit: (GroupActivity) -> Void
    
    var body: some View {
        VStack(spacing: AppStyles.padding) {
            HStack {
                Text("建立新揪團")
                    .font(AppStyles.Typography.title)
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Photo picker and preview
            if let selectedImage {
                VStack {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .cornerRadius(AppStyles.cornerRadius)
                    
                    if isProcessing {
                        ProgressView("OCR 處理中...")
                            .padding(.top, 8)
                    } else if isGenerating {
                        ProgressView("AI 生成文案中...")
                            .padding(.top, 8)
                    }
                }
            } else {
                PhotosPicker(selection: $selectedImageItem, matching: .images) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.title3)
                        
                        Text("拍攝或上傳優惠圖片")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(AppStyles.cornerRadius)
                }
                .onChange(of: selectedImageItem) { _, newValue in
                    if let newValue {
                        isProcessing = true
                        loadTransferable(from: newValue)
                    }
                }
            }
            
            // Form fields
            Group {
                // Group type selection
                Picker("優惠類型", selection: $groupType) {
                    Text("咖啡優惠").tag(GroupType.coffeeDeal)
                    Text("美食優惠").tag(GroupType.foodDeal)
                    Text("共乘").tag(GroupType.rideShare)
                    Text("購物優惠").tag(GroupType.shopping)
                    Text("其他").tag(GroupType.other)
                }
                .pickerStyle(.segmented)
                
                TextField("活動標題", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(AppStyles.Typography.body)
                
                TextField("活動描述", text: $activityDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(AppStyles.Typography.body)
                
                // Expiry time
                VStack(alignment: .leading) {
                    Text("優惠有效時間: \(Int(expiryHours)) 小時")
                        .font(AppStyles.Typography.caption)
                    
                    Slider(value: $expiryHours, in: 0.5...24, step: 0.5)
                }
            }
            
            HStack {
                Button {
                    simulateAIGeneration()
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("AI生成文案")
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(AppStyles.cornerRadius)
                }
                .disabled(selectedImage == nil || isGenerating)
                
                Spacer()
                
                Button {
                    submitGroup()
                } label: {
                    Text("立即揪團")
                        .font(AppStyles.Typography.button)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            (title.isEmpty || activityDescription.isEmpty) ? 
                                LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing) : 
                                AppStyles.primaryGradient
                        )
                        .cornerRadius(AppStyles.cornerRadius)
                }
                .disabled(title.isEmpty || activityDescription.isEmpty)
            }
        }
        .padding(AppStyles.padding)
        .background(.ultraThinMaterial)
        .cornerRadius(AppStyles.cornerRadius)
        .shadow(
            color: AppStyles.shadowColor,
            radius: AppStyles.shadowRadius,
            x: AppStyles.shadowX,
            y: AppStyles.shadowY
        )
        .frame(width: UIScreen.main.bounds.width - 40)
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
                activityDescription = "星巴克指定大杯飲品買一送一，限今日！要不要一起？省一半錢！"
            } else if groupType == .foodDeal {
                title = "麥當勞大麥克優惠"
                activityDescription = "麥當勞大麥克買一送一，快來一起分享美味漢堡！限時特價！"
            } else if groupType == .rideShare {
                title = "台北到桃園共乘"
                activityDescription = "今晚8點從台北到桃園，有人要拼車嗎？平分車資，省時又省錢！"
            }
            
            isGenerating = false
        }
    }
    
    private func submitGroup() {
        // Create dummy data for location
        let location = Location(
            latitude: 25.033,
            longitude: 121.565,
            placeName: "台北市"
        )
        
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
        
        onSubmit(newActivity)
        isPresented = false
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        
        CreateGroupDialog(
            isPresented: .constant(true),
            onSubmit: { _ in print("Group created") }
        )
    }
} 