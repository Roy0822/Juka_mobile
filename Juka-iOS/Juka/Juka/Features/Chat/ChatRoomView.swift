import SwiftUI
import SwiftData

struct FullScreenChatRoomView: View {
    let activity: GroupActivity
    @Binding var isPresented: Bool
    
    @State private var chatMessages: [Juka.ChatMessage] = []
    @State private var newMessageText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat room header
            VStack(spacing: 4) {
                HStack {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    
                    Spacer()
                    
                    Text(activity.title)
                        .font(AppStyles.Typography.subtitle)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    GroupTypeIcon(type: activity.type)
                        .frame(width: 24, height: 24)
                }
                
                Text("\(activity.participantIds.count + 1) 位參與者")
                    .font(AppStyles.Typography.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial)
            
            // Chat messages
            ScrollView {
                LazyVStack(spacing: AppStyles.smallPadding) {
                    ForEach(chatMessages) { message in
                        ChatMessageView(
                            message: message,
                            isCurrentUser: message.senderId == "currentUser"
                        )
                    }
                }
                .padding()
            }
            
            // Message input field
            HStack {
                TextField("輸入訊息...", text: $newMessageText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(AppStyles.cornerRadius)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(AppStyles.primary)
                        .clipShape(Circle())
                }
            }
            .padding()
        }
        .onAppear {
            loadSampleMessages()
        }
    }
    
    private func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        
        let newMessage = Juka.ChatMessage(
            groupId: activity.id,
            senderId: "currentUser",
            senderName: "我",
            content: newMessageText
        )
        
        chatMessages.append(newMessage)
        newMessageText = ""
    }
    
    private func loadSampleMessages() {
        let messages = [
            Juka.ChatMessage(
                groupId: activity.id,
                senderId: activity.creatorId,
                senderName: activity.creatorName,
                content: "大家好！我在\(activity.location.placeName ?? "地點")，有人要一起來嗎？"
            ),
            Juka.ChatMessage(
                groupId: activity.id,
                senderId: "user5",
                senderName: "王小美",
                content: "我有興趣！還有位置嗎？"
            ),
            Juka.ChatMessage(
                groupId: activity.id,
                senderId: activity.creatorId,
                senderName: activity.creatorName,
                content: "有的！歡迎加入"
            ),
            Juka.ChatMessage(
                groupId: activity.id,
                senderId: "currentUser",
                senderName: "我",
                content: "我也想參加！"
            )
        ]
        
        chatMessages = messages
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
    
    FullScreenChatRoomView(
        activity: activity,
        isPresented: .constant(true)
    )
} 