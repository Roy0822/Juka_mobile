import SwiftUI
import MapKit

struct JoinGroupView: View {
    let activity: GroupActivity
    @State private var comments: String = ""
    @State private var phoneNumber: String = ""
    @State private var showSuccessView = false
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Group Info Section
                    groupInfoSection
                    
                    // Location Section
                    locationSection
                    
                    // User Information Section
                    userInfoSection
                    
                    // Terms and Conditions
                    termsSection
                    
                    // Join Button
                    Button(action: {
                        // Submit join request
                        showSuccessView = true
                    }) {
                        Text("確認加入")
                            .font(AppStyles.Typography.button)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppStyles.primaryGradient)
                            .cornerRadius(AppStyles.cornerRadius)
                    }
                    .padding(.top, 16)
                }
                .padding()
            }
            .navigationTitle("加入揪團")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .fullScreenCover(isPresented: $showSuccessView) {
                JoinGroupSuccessView(activity: activity)
            }
        }
    }
    
    private var groupInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with title and type
            HStack {
                Text(activity.title)
                    .font(AppStyles.Typography.title)
                
                Spacer()
                
                GroupTypeIcon(type: activity.type)
                    .frame(width: 40, height: 40)
            }
            
            // Description
            Text(activity.activityDescription)
                .font(AppStyles.Typography.body)
                .padding(.vertical, 4)
            
            Divider()
            
            // Details
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(AppStyles.primary)
                        .frame(width: 24)
                    
                    Text("發起人: \(activity.creatorName)")
                        .font(AppStyles.Typography.body)
                }
                
                if let expiresAt = activity.expiresAt {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(AppStyles.primary)
                            .frame(width: 24)
                        
                        Text("有效期限至: \(expiresAt, format: Date.FormatStyle(date: .numeric, time: .shortened))")
                            .font(AppStyles.Typography.body)
                    }
                }
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(AppStyles.primary)
                        .frame(width: 24)
                    
                    let count = activity.participantIds.count + 1 // +1 for creator
                    Text("目前已有 \(count) 人參與")
                        .font(AppStyles.Typography.body)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("活動地點")
                .font(AppStyles.Typography.subtitle)
            
            Map(initialPosition: .region(
                MKCoordinateRegion(
                    center: activity.location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))
            ) {
                Marker(activity.title, coordinate: activity.location.coordinate)
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: AppStyles.cornerRadius))
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                
                Text(activity.location.placeName ?? "Unknown Location")
                    .font(AppStyles.Typography.body)
                
                Spacer()
                
                Button(action: {
                    // Open in Maps app with the coordinates
                    let url = URL(string: "maps://?ll=\(activity.location.coordinate.latitude),\(activity.location.coordinate.longitude)")
                    if let url = url, UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("在地圖中打開")
                        .font(.caption)
                        .foregroundColor(AppStyles.primary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var userInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("聯絡資訊")
                .font(AppStyles.Typography.subtitle)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("聯絡電話 (選填)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("輸入電話", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .padding()
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("備註 (選填)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $comments)
                        .frame(height: 100)
                        .padding(4)
                        .background(Color(.systemGray6).opacity(0.5))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var termsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppStyles.primary)
                
                Text("當你加入揪團，你同意我們的服務條款和隱私政策。揪團發起人將能看到你的基本資料。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(alignment: .top) {
                Image(systemName: "bell.fill")
                    .foregroundColor(AppStyles.primary)
                
                Text("加入後，你將能進入群組聊天室，與其他參與者交流。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct JoinGroupSuccessView: View {
    let activity: GroupActivity
    @Environment(\.dismiss) private var dismiss
    @State private var showChatRoom = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Success animation
                LottieView(name: "success", loopMode: .playOnce)
                    .frame(width: 200, height: 200)
                
                // Success message
                Text("成功加入揪團！")
                    .font(AppStyles.Typography.title)
                    .multilineTextAlignment(.center)
                
                Text("您已成功加入「\(activity.title)」")
                    .font(AppStyles.Typography.body)
                    .multilineTextAlignment(.center)
                
                // Group info summary
                GroupSummaryView(activity: activity)
                    .padding(.horizontal)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showChatRoom = true
                    }) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("前往聊天室")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppStyles.primaryGradient)
                        .foregroundColor(.white)
                        .cornerRadius(AppStyles.cornerRadius)
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("返回地圖")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(AppStyles.primary)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                                    .stroke(AppStyles.primary, lineWidth: 1)
                            )
                    }
                }
                .padding()
            }
            .padding()
            .fullScreenCover(isPresented: $showChatRoom) {
                ChatRoomView(activity: activity, isPresented: $showChatRoom)
            }
        }
    }
}

struct GroupSummaryView: View {
    let activity: GroupActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                GroupTypeIcon(type: activity.type)
                    .frame(width: 32, height: 32)
                
                Text(activity.title)
                    .font(AppStyles.Typography.subtitle)
                
                Spacer()
            }
            
            Divider()
            
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(AppStyles.primary)
                
                Text("發起人: \(activity.creatorName)")
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                
                Text(activity.location.placeName ?? "")
                    .font(.subheadline)
            }
            
            if let expiresAt = activity.expiresAt {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(AppStyles.primary)
                    
                    Text("有效期限至: \(expiresAt, format: Date.FormatStyle(date: .abbreviated, time: .shortened))")
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(AppStyles.cornerRadius)
    }
}

struct LottieView: View {
    let name: String
    let loopMode: LoopMode
    
    enum LoopMode {
        case loop
        case playOnce
    }
    
    // In a real app, this would use Lottie animations
    // This is a placeholder using SF Symbols instead
    var body: some View {
        ZStack {
            Circle()
                .fill(AppStyles.primary.opacity(0.2))
                .frame(width: 200, height: 200)
            
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(AppStyles.primary)
                .frame(width: 100, height: 100)
        }
    }
}

#Preview {
    let location = Location(latitude: 25.033, longitude: 121.565, placeName: "台北 101")
    let activity = GroupActivity(
        title: "星巴克買一送一",
        activityDescription: "限時優惠！大杯拿鐵買一送一，找人一起分享",
        expiresAt: Date().addingTimeInterval(3600),
        location: location,
        creatorId: "user1",
        creatorName: "吳盛偉",
        type: .coffeeDeal
    )
    
    return JoinGroupView(activity: activity)
} 