import SwiftUI
import MapKit

struct GroupStatusView: View {
    let activity: GroupActivity
    @State private var shareLink: String = "https://juka.app/groups/12345"
    @State private var showShareSheet = false
    @State private var showCopyNotification = false
    @State private var showQRView = false
    @State private var participants: [MockParticipant] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Success banner
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                        
                    Text("揪團已成功建立！")
                        .font(AppStyles.Typography.title)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                
                // Group card
                GroupActivityCard(activity: activity, distance: 0) {
                    // No action
                }
                .padding(.horizontal)
                
                // Invite section
                VStack(spacing: 20) {
                    Text("分享邀請連結")
                        .font(AppStyles.Typography.subtitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Link with Copy Button
                    HStack {
                        Text(shareLink)
                            .font(.subheadline)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .lineLimit(1)
                        
                        Button(action: {
                            UIPasteboard.general.string = shareLink
                            showCopyNotification = true
                            
                            // Hide notification after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showCopyNotification = false
                            }
                        }) {
                            Image(systemName: "doc.on.doc")
                                .font(.title3)
                                .padding(12)
                                .background(AppStyles.primary)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    
                    // Sharing options
                    HStack(spacing: 24) {
                        Spacer()
                        
                        Button(action: {
                            showQRView = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "qrcode")
                                    .font(.title)
                                    .foregroundColor(AppStyles.primary)
                                Text("QR碼")
                                    .font(.caption)
                            }
                        }
                        
                        Button(action: {
                            showShareSheet = true
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title)
                                    .foregroundColor(AppStyles.primary)
                                Text("分享")
                                    .font(.caption)
                            }
                        }
                        
                        Spacer()
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Location section
                VStack(alignment: .leading, spacing: 16) {
                    Text("活動地點")
                        .font(AppStyles.Typography.subtitle)
                    
                    ZStack(alignment: .bottomTrailing) {
                        Map(initialPosition: .region(
                            MKCoordinateRegion(
                                center: activity.location.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                            ))
                        ) {
                            Marker(activity.title, coordinate: activity.location.coordinate)
                                .tint(markerColor(for: activity.type))
                        }
                        .frame(height: 180)
                        .cornerRadius(AppStyles.cornerRadius)
                        
                        Button(action: {
                            // Open in Maps app
                        }) {
                            Text("導航")
                                .font(AppStyles.Typography.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(AppStyles.primary)
                                .foregroundColor(.white)
                                .cornerRadius(AppStyles.cornerRadius)
                        }
                        .padding(12)
                    }
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        
                        Text(activity.location.placeName ?? "位置")
                            .font(AppStyles.Typography.body)
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                // Participants
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("參與者")
                            .font(AppStyles.Typography.subtitle)
                            
                        Text("(\(participants.count))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if participants.isEmpty {
                        Text("還沒有參與者，快邀請朋友加入吧！")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(participants) { participant in
                            HStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(participant.initial)
                                            .font(.system(size: 18, weight: .medium))
                                            .foregroundColor(.primary)
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text(participant.name)
                                        .font(AppStyles.Typography.body)
                                    
                                    Text(participant.joinTime)
                                        .font(AppStyles.Typography.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if participant.isCreator {
                                    Text("發起人")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppStyles.primary.opacity(0.2))
                                        .foregroundColor(AppStyles.primary)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Open chat room
                    }) {
                        HStack {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("聊天室")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppStyles.primaryGradient)
                        .foregroundColor(.white)
                        .cornerRadius(AppStyles.cornerRadius)
                    }
                    
                    Button(action: {
                        // End group activity early
                    }) {
                        Text("提前結束揪團")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .overlay(
            Group {
                if showCopyNotification {
                    VStack {
                        Text("已複製連結")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                        
                        Spacer()
                    }
                    .transition(.opacity)
                    .zIndex(1)
                    .padding(.top, 16)
                }
            }
            .animation(.easeInOut, value: showCopyNotification)
        )
        .navigationTitle("揪團狀態")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Go to homepage or dismiss
                    dismiss()
                }) {
                    Text("完成")
                        .bold()
                }
            }
        }
        .sheet(isPresented: $showQRView) {
            QRCodeView(shareLink: shareLink)
        }
        .onAppear {
            loadMockParticipants()
        }
    }
    
    private func loadMockParticipants() {
        let creator = MockParticipant(
            id: UUID().uuidString,
            name: "我", 
            initial: "我",
            joinTime: "剛剛",
            isCreator: true
        )
        
        participants = [creator]
        
        // Simulate other participants joining (for demo purposes)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let newParticipant = MockParticipant(
                id: UUID().uuidString,
                name: "張小明",
                initial: "張",
                joinTime: "剛剛",
                isCreator: false
            )
            
            participants.append(newParticipant)
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
}

struct GroupSection<Content: View, Header: View>: View {
    let content: Content
    let header: Header
    
    init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) {
        self.content = content()
        self.header = header()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            header
                .padding(.horizontal)
            
            content
                .padding(.horizontal)
                .padding(.bottom, 8)
                .background(Color.white)
                .cornerRadius(AppStyles.cornerRadius)
                .shadow(color: AppStyles.shadowColor, radius: 2, x: 0, y: 1)
                .padding(.horizontal)
        }
    }
}

struct QRCodeView: View {
    let shareLink: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                // Simulated QR code (in a real app, generate actual QR code)
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                
                Text(shareLink)
                    .font(.caption)
                    .padding()
                
                Text("掃描此 QR 碼加入揪團")
                    .font(AppStyles.Typography.body)
                
                Spacer()
                
                Button("儲存至相簿") {
                    // Save QR code to photos logic would go here
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .navigationTitle("揪團 QR 碼")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct MockParticipant: Identifiable {
    let id: String
    let name: String
    let initial: String
    let joinTime: String
    let isCreator: Bool
}

#Preview {
    NavigationStack {
        GroupStatusView(activity: GroupActivity(
            title: "星巴克買一送一",
            activityDescription: "星巴克指定飲品買一送一優惠",
            expiresAt: Date().addingTimeInterval(3600),
            location: Location(latitude: 25.033, longitude: 121.565, placeName: "台北 101"),
            creatorId: "user1",
            creatorName: "我",
            type: .coffeeDeal
        ))
    }
} 