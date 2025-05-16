import SwiftUI

struct ChatMessageView: View {
    let message: Juka.ChatMessage
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading) {
                if !isCurrentUser {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 8)
                }
                
                Text(message.content)
                    .padding(12)
                    .background(isCurrentUser ? 
                        AppStyles.primaryGradient : 
                        LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                    )
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .cornerRadius(18)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct ChatInputView: View {
    @Binding var messageText: String
    let onSendMessage: () -> Void
    
    var body: some View {
        HStack {
            TextField("輸入訊息", text: $messageText)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(AppStyles.cornerRadius)
            
            Button(action: onSendMessage) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(messageText.isEmpty ? .gray : AppStyles.primary)
            }
            .disabled(messageText.isEmpty)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

struct ChatRoomHeader: View {
    let activity: GroupActivity
    let participantCount: Int
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                GroupTypeIcon(type: activity.type)
                    .frame(width: 32, height: 32)
                
                VStack(alignment: .leading) {
                    Text(activity.title)
                        .font(AppStyles.Typography.subtitle)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 12))
                        
                        Text("\(participantCount) 位參與者")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let expiresAt = activity.expiresAt {
                    TimeRemainingLabel(expiresAt: expiresAt)
                }
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(.ultraThinMaterial)
    }
}

struct ExpirableMessageLabel: View {
    var isUserMessage: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "timer")
                .font(.caption2)
            
            Text("此訊息將於會話結束後自動銷毀")
                .font(.caption2)
        }
        .foregroundColor(.secondary)
        .padding(.horizontal)
        .padding(.top, 4)
        .frame(maxWidth: .infinity, alignment: isUserMessage ? .trailing : .leading)
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
    
    let message1 = Juka.ChatMessage(
        groupId: activity.id,
        senderId: "user1",
        senderName: "吳盛偉",
        content: "大家好！我在台北101星巴克，有人要一起買一送一嗎？"
    )
    
    let message2 = Juka.ChatMessage(
        groupId: activity.id,
        senderId: "user2",
        senderName: "李小明",
        content: "我要！大概15分鐘後到，可以等我嗎？"
    )
    
    VStack {
        ChatRoomHeader(
            activity: activity,
            participantCount: 3,
            onClose: { print("Close chat") }
        )
        
        Spacer()
        
        ChatMessageView(message: message1, isCurrentUser: false)
        ChatMessageView(message: message2, isCurrentUser: true)
        ExpirableMessageLabel(isUserMessage: true)
        
        Spacer()
        
        ChatInputView(
            messageText: .constant(""),
            onSendMessage: { print("Send message") }
        )
    }
} 
