import SwiftUI

struct MessageListView: View {
    let activities: [GroupActivity]
    let onSelectChat: (GroupActivity) -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if activities.isEmpty {
                    emptyStateView
                        .padding(.top, 60)
                } else {
                    ForEach(activities) { activity in
                        Button {
                            onSelectChat(activity)
                        } label: {
                            HStack(spacing: 12) {
                                // Group icon
                                ZStack {
                                    Circle()
                                        .fill(iconGradient(for: activity.type))
                                        .frame(width: 50, height: 50)
                                        .shadow(color: iconColor(for: activity.type).opacity(0.3), radius: 2, x: 0, y: 1)
                                    
                                    Image(systemName: iconName(for: activity.type))
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(activity.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(activity.creatorName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text(formatDate(activity.createdAt))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    // Unread message indicator (placeholder)
                                    Circle()
                                        .fill(AppStyles.primary)
                                        .frame(width: 10, height: 10)
                                }
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(
                                Rectangle()
                                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.leading, 78)
                    }
                }
            }
        }
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemGray6).opacity(0.3))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 20)
            
            Text("沒有活躍的聊天")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("參與揪團後，你可以與群組成員聊天")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "昨天"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: date)
        }
    }
    
    private func iconName(for type: GroupType) -> String {
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
    
    private func iconColor(for type: GroupType) -> Color {
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
    
    private func iconGradient(for type: GroupType) -> LinearGradient {
        let color = iconColor(for: type)
        return LinearGradient(
            colors: [color, color.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
} 