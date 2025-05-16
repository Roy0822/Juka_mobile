import SwiftUI
import MapKit

struct JoinGroupView: View {
    let activity: GroupActivity
    let isJoined: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var comments: String = ""
    @State private var phoneNumber: String = ""
    @State private var isProcessing = false
    @State private var showSuccessView = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    if showSuccessView {
                        SuccessView(activity: activity) {
                            isJoined()
                            dismiss()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 24) {
                                GroupInfoCard(activity: activity)
                                
                                LocationCard(activity: activity)
                                
                                ContactInfoCard(
                                    phoneNumber: $phoneNumber,
                                    comments: $comments
                                )
                                
                                TermsCard()
                                
                                Button(action: {
                                    joinGroup()
                                }) {
                                    HStack {
                                        if isProcessing {
                                            ProgressView()
                                                .tint(.white)
                                                .padding(.trailing, 8)
                                        }
                                        
                                        Text(isProcessing ? "處理中..." : "確認加入")
                                            .font(.system(size: 16, weight: .bold))
                                    }
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
                                .disabled(isProcessing)
                                .padding(.vertical, 8)
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("加入揪團")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(accentColor1)
                }
            }
        }
    }
    
    private func joinGroup() {
        isProcessing = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isProcessing = false
            showSuccessView = true
        }
    }
}

struct GroupInfoCard: View {
    let activity: GroupActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(activity.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.primary)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: activity.type.icon)
                        .font(.system(size: 16))
                        .foregroundColor(accentColor1)
                }
            }
            
            Text(activity.activityDescription)
                .font(.system(size: 14))
                .foregroundColor(Color.primary.opacity(0.8))
                .padding(.vertical, 4)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
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
                    text: "目前已有 \(activity.participantIds.count + 1) 人參與"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 4, x:0, y:1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct LocationCard: View {
    let activity: GroupActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("活動地點")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.primary)
            
            ZStack {
                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: activity.location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ))
                ) {
                    Marker("", coordinate: activity.location.coordinate)
                        .tint(accentColor1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(height: 150)
                .mapStyle(.standard)
            }
            
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(accentColor1)
                    .font(.system(size: 16))
                
                Text(activity.location.placeName ?? "未知位置")
                    .font(.system(size: 14))
                    .foregroundColor(Color.primary.opacity(0.8))
                
                Spacer()
                
                Button(action: {
                    openInMaps()
                }) {
                    Text("在地圖中打開")
                        .font(.system(size: 12))
                        .foregroundColor(accentColor1)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(accentColor1, lineWidth: 1)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 4, x:0, y:1)
        )
    }
    
    private func openInMaps() {
        let url = URL(string: "maps://?ll=\(activity.location.coordinate.latitude),\(activity.location.coordinate.longitude)")
        if let url = url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

struct ContactInfoCard: View {
    @Binding var phoneNumber: String
    @Binding var comments: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("聯絡資訊")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.primary)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("聯絡電話 (選填)")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondary)
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(accentColor1)
                            .padding(.leading, 10)
                        
                        TextField("輸入電話", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .padding(10)
                            .foregroundColor(Color.primary)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("備註 (選填)")
                        .font(.system(size: 14))
                        .foregroundColor(Color.secondary)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $comments)
                            .padding(8)
                            .frame(height: 100)
                            .foregroundColor(Color.primary)
                            .scrollContentBackground(.hidden)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.secondarySystemBackground))
                            )
                        
                        if comments.isEmpty {
                            Text("輸入備註...")
                                .foregroundColor(Color.secondary)
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 4, x:0, y:1)
        )
    }
}

struct TermsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(accentColor1)
                
                Text("當你加入揪團，你同意我們的服務條款和隱私政策。揪團發起人將能看到你的基本資料。")
                    .font(.system(size: 12))
                    .foregroundColor(Color.secondary)
            }
            
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "bell.fill")
                    .foregroundColor(accentColor1)
                
                Text("加入後，你將能進入群組聊天室，與其他參與者交流。")
                    .font(.system(size: 12))
                    .foregroundColor(Color.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 4, x:0, y:1)
        )
    }
}

struct ChatRoomView: View {
    let activity: GroupActivity
    
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [MessageItem] = []
    @State private var showSuggestions = false
    @State private var suggestedReplies: [String] = []
    
    struct MessageItem: Identifiable {
        let id = UUID()
        let senderId: String
        let senderName: String
        let content: String
        let timestamp: Date
        let isCurrentUser: Bool
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(accentColor1)
                }
                
                Spacer()
                
                Text(activity.title)
                    .font(.system(size: 18, weight: .bold))
                
                Spacer()
                
                Button(action: {
                    // 群組設定選項
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                        .foregroundColor(accentColor1)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.gray.opacity(0.3)),
                alignment: .bottom
            )
            
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.3))
                            
                            Text("今天")
                                .font(.system(size: 12))
                                .foregroundColor(Color.secondary)
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(Color.gray.opacity(0.3))
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        HStack {
                            Spacer()
                            Text("歡迎加入「\(activity.title)」揪團")
                                .font(.system(size: 12))
                                .foregroundColor(Color.secondary)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 10)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            Spacer()
                        }
                        
                        ForEach(getSampleMessages()) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if messages.isEmpty {
                            HStack {
                                Text("大家好，我是新加入的成員！")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(actionGradient)
                                    .foregroundColor(.white)
                                    .cornerRadius(18)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                        }
                        
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.bottom, 10)
                    .onChange(of: messages.count) { _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                            
                            // 當收到新訊息且不是自己發的，生成推薦回覆
                            if !lastMessage.isCurrentUser {
                                generateSuggestedReplies(for: lastMessage)
                            }
                        }
                    }
                }
            }
            
            // AI推薦回覆
            if showSuggestions && !suggestedReplies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestedReplies, id: \.self) { suggestion in
                            Button(action: {
                                messageText = suggestion
                                sendMessage()
                            }) {
                                Text(suggestion)
                                    .font(.system(size: 14))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray5))
                                    .foregroundColor(.primary)
                                    .cornerRadius(16)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 40)
                .background(Color(.systemBackground))
            }
            
            HStack(spacing: 10) {
                Button(action: {
                    // 添加照片
                }) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 22))
                        .foregroundColor(accentColor1)
                }
                
                TextField("輸入訊息...", text: $messageText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: {
                    showSuggestions.toggle()
                }) {
                    Image(systemName: showSuggestions ? "lightbulb.fill" : "lightbulb")
                        .font(.system(size: 20))
                        .foregroundColor(accentColor1)
                }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(messageText.isEmpty ? Color.gray : accentColor1)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color.gray.opacity(0.3)),
                alignment: .top
            )
        }
        .navigationBarHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let newMessage = MessageItem(
                    senderId: activity.creatorId,
                    senderName: activity.creatorName,
                    content: "歡迎加入我們的揪團！請問大家方便什麼時候碰面？",
                    timestamp: Date(),
                    isCurrentUser: false
                )
                
                messages.append(newMessage)
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let newMessage = MessageItem(
            senderId: "currentUser",
            senderName: "我",
            content: messageText,
            timestamp: Date(),
            isCurrentUser: true
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // 清空建議
        showSuggestions = false
    }
    
    private func getSampleMessages() -> [MessageItem] {
        [
            MessageItem(
                senderId: activity.creatorId,
                senderName: activity.creatorName,
                content: "大家好！感謝大家參加這個揪團活動。",
                timestamp: Date().addingTimeInterval(-60*15),
                isCurrentUser: false
            )
        ]
    }
    
    private func generateSuggestedReplies(for message: MessageItem) {
        // 根據消息內容生成建議回覆
        var suggestions: [String] = []
        
        if message.content.contains("時候") || message.content.contains("碰面") {
            suggestions.append("我週末都有空！")
            suggestions.append("我平日晚上比較方便")
            suggestions.append("這週五晚上如何？")
        } else if message.content.contains("地點") || message.content.contains("在哪") {
            suggestions.append("公館捷運站附近可以嗎？")
            suggestions.append("我住在東區，附近都方便")
            suggestions.append("有推薦的地點嗎？")
        } else if message.content.contains("感謝") || message.content.contains("謝謝") {
            suggestions.append("不客氣！很高興認識大家")
            suggestions.append("我也很期待活動！")
            suggestions.append("謝謝邀請，期待見面")
        } else if message.content.contains("介紹") || message.content.contains("自我") {
            suggestions.append("大家好，我是新加入的成員！")
            suggestions.append("很高興認識大家，希望能一起玩得開心")
            suggestions.append("我是第一次參加這種活動，請多指教")
        } else {
            // 通用回覆
            suggestions.append("了解！")
            suggestions.append("聽起來不錯")
            suggestions.append("好的，沒問題")
            suggestions.append("我同意")
        }
        
        // 設置建議回覆並顯示
        suggestedReplies = suggestions
        showSuggestions = true
    }
}

struct MessageBubble: View {
    let message: ChatRoomView.MessageItem
    
    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer()
                
                Text(message.content)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(actionGradient)
                    .foregroundColor(.white)
                    .cornerRadius(18)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(message.senderName)
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                    
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .foregroundColor(.primary)
                        .cornerRadius(18)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal)
    }
}

struct SuccessView: View {
    let activity: GroupActivity
    let onContinue: () -> Void
    
    @State private var showChatRoom = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(actionGradient.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(actionGradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            Text("成功加入揪團！")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.primary)
            
            Text("您已成功加入「\(activity.title)」")
                .font(.system(size: 16))
                .foregroundColor(Color.primary.opacity(0.8))
                .multilineTextAlignment(.center)
            
            GroupInfoCard(activity: activity)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: {
                    showChatRoom = true
                }) {
                    HStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("進入聊天室")
                    }
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
                
                Button(action: onContinue) {
                    Text("返回地圖")
                        .foregroundColor(accentColor1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(accentColor1, lineWidth: 1)
                        )
                }
            }
            .padding()
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $showChatRoom) {
            ChatRoomView(activity: activity)
        }
    }
}

#Preview {
    let location = Location(
        latitude: 25.033,
        longitude: 121.565,
        placeName: "台北 101"
    )
    
    let activity = GroupActivity(
        title: "星巴克買一送一",
        activityDescription: "限時優惠！大杯拿鐵買一送一，找人一起分享",
        expiresAt: Date().addingTimeInterval(3600),
        location: location,
        creatorId: "user1",
        creatorName: "吳盛偉",
        type: .coffeeDeal
    )
    
    return JoinGroupView(activity: activity, isJoined: {})
} 