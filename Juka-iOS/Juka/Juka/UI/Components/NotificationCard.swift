import SwiftUI

struct NotificationCard: View {
    let activity: GroupActivity
    let creatorName: String
    let distance: Double
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    var body: some View {
        VStack(spacing: AppStyles.smallPadding) {
            HStack {
                GroupTypeIcon(type: activity.type)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.title)
                        .font(AppStyles.Typography.subtitle)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppStyles.primary)
                        
                        Text("\(creatorName)，距離你 \(formatDistance(distance))")
                            .font(AppStyles.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let expiresAt = activity.expiresAt {
                    TimeRemainingLabel(expiresAt: expiresAt)
                }
            }
            
            Text(activity.activityDescription)
                .font(AppStyles.Typography.body)
                .lineLimit(2)
                .padding(.vertical, 4)
            
            HStack(spacing: 12) {
                Button(action: onDecline) {
                    Text("拒絕")
                        .font(AppStyles.Typography.button)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemBackground))
                        .cornerRadius(AppStyles.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onAccept) {
                    Text("要要要！")
                        .font(AppStyles.Typography.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppStyles.primaryGradient)
                        .cornerRadius(AppStyles.cornerRadius)
                }
                .buttonStyle(PlainButtonStyle())
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

#Preview {
    let location = Location(latitude: 25.033, longitude: 121.565, placeName: "台北 101")
    let activity = GroupActivity(
        title: "星巴克買一送一",
        activityDescription: "限時優惠！大杯拿鐵買一送一，找人一起分享，趕快加入吧！",
        expiresAt: Date().addingTimeInterval(3600),
        location: location,
        creatorId: "user1",
        creatorName: "吳盛偉",
        type: .coffeeDeal
    )
    
    NotificationCard(
        activity: activity,
        creatorName: "吳盛偉",
        distance: 200,
        onAccept: { print("Accepted") },
        onDecline: { print("Declined") }
    )
    .padding()
    .previewLayout(.sizeThatFits)
} 
