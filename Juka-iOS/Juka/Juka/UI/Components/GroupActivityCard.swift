import SwiftUI

struct GroupActivityCard: View {
    let activity: GroupActivity
    let distance: Double
    let onTap: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                // Type icon with gradient background
                ZStack {
                    Circle()
                        .fill(iconGradient)
                        .frame(width: 52, height: 52)
                        .shadow(color: iconColor.opacity(0.3), radius: 2, x: 0, y: 2)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                }
                .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    Text(activity.title)
                        .font(AppStyles.Typography.subtitle)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    // Description - only shown if not empty
                    if !activity.activityDescription.isEmpty {
                        Text(activity.activityDescription)
                            .font(AppStyles.Typography.body)
                            .foregroundColor(.primary.opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    Spacer(minLength: 4)
                    
                    // Bottom row with metadata
                    HStack(spacing: 12) {
                        // Creator
                        Label(
                            title: { Text(activity.creatorName).font(.caption) },
                            icon: { Image(systemName: "person.fill").font(.caption2) }
                        )
                        .foregroundColor(.secondary)
                        
                        // Distance pill
                        HStack(spacing: 2) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.caption2)
                            
                            Text(formatDistance(distance))
                                .font(.caption)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray6).opacity(0.7))
                        .cornerRadius(10)
                        .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // Time remaining (if applicable)
                        if let expiresAt = activity.expiresAt {
                            TimeRemainingLabel(expiresAt: expiresAt)
                        }
                    }
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemBackground))
                    .shadow(
                        color: AppStyles.shadowColor.opacity(0.1),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                    .stroke(Color.secondary.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconName: String {
        switch activity.type {
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
    
    private var iconColor: Color {
        switch activity.type {
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
    
    private var iconGradient: LinearGradient {
        LinearGradient(
            colors: [iconColor, iconColor.opacity(0.7)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance))m"
        } else {
            let km = distance / 1000
            return String(format: "%.1f km", km)
        }
    }
}

struct TimeRemainingLabel: View {
    let expiresAt: Date
    @State private var timeRemaining: String = ""
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock.fill")
                .font(.caption2)
            
            Text(timeRemaining)
                .font(.caption)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(AppStyles.accent.opacity(0.15))
        .cornerRadius(10)
        .foregroundColor(AppStyles.accent)
        .onAppear {
            updateTimeRemaining()
        }
        .onReceive(timer) { _ in
            updateTimeRemaining()
        }
    }
    
    private func updateTimeRemaining() {
        let remaining = expiresAt.timeIntervalSince(Date())
        
        if remaining <= 0 {
            timeRemaining = "已結束"
            return
        }
        
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        
        if hours > 0 {
            timeRemaining = "\(hours)h \(minutes)m"
        } else {
            timeRemaining = "\(minutes)m"
        }
    }
}

// Legacy GroupTypeIcon for compatibility with other views
struct GroupTypeIcon: View {
    let type: GroupType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(iconBackground)
                .frame(width: 32, height: 32)
            
            Image(systemName: iconName)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .bold))
        }
    }
    
    private var iconName: String {
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
    
    private var iconBackground: Color {
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
    
    GroupActivityCard(activity: activity, distance: 200) {
        print("Card tapped")
    }
    .padding()
    .previewLayout(.sizeThatFits)
} 