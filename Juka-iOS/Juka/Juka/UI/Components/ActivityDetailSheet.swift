import SwiftUI

struct FullScreenActivityDetailSheet: View {
    let activity: GroupActivity
    let onJoin: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppStyles.padding) {
                // Header with title and type
                HStack {
                    Text(activity.title)
                        .font(AppStyles.Typography.title)
                    
                    Spacer()
                    
                    GroupTypeIcon(type: activity.type)
                }
                
                // Description
                Text(activity.activityDescription)
                    .font(AppStyles.Typography.body)
                    .padding(.vertical, 4)
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(AppStyles.primary)
                        
                        Text("發起人: \(activity.creatorName)")
                            .font(AppStyles.Typography.body)
                    }
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(AppStyles.primary)
                        
                        Text(activity.location.placeName ?? "Unknown Location")
                            .font(AppStyles.Typography.body)
                    }
                    
                    if let expiresAt = activity.expiresAt {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(AppStyles.primary)
                            
                            Text("有效期限至: \(expiresAt, format: Date.FormatStyle(date: .numeric, time: .shortened))")
                                .font(AppStyles.Typography.body)
                        }
                    }
                }
                .padding(.vertical)
                
                Spacer()
                
                // Join button
                Button(action: onJoin) {
                    HStack {
                        Image(systemName: "person.badge.plus")
                        Text("加入揪團")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppStyles.primaryGradient)
                    .foregroundColor(.white)
                    .cornerRadius(AppStyles.cornerRadius)
                }
                .padding(.top)
            }
            .padding()
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
    
    FullScreenActivityDetailSheet(
        activity: activity,
        onJoin: { print("Joined") }
    )
} 