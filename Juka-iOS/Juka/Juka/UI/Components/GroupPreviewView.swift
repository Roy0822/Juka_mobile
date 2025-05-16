import SwiftUI
import UIKit
import MapKit

// MARK: - Missing Components

struct GroupTypeBadge: View {
    let type: GroupType
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.system(size: 12, weight: .semibold))
            
            Text(typeName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(typeColor.opacity(0.15))
        )
        .foregroundColor(typeColor)
        .overlay(
            Capsule()
                .stroke(typeColor.opacity(0.3), lineWidth: 1)
        )
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
    
    private var typeName: String {
        switch type {
        case .coffeeDeal:
            return "咖啡"
        case .foodDeal:
            return "美食"
        case .rideShare:
            return "共乘"
        case .shopping:
            return "購物"
        case .other:
            return "其他"
        }
    }
    
    private var typeColor: Color {
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

struct ShareSheet: View {
    let activity: GroupActivity
    @Environment(\.dismiss) var dismiss
    @State private var showQRCode = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Share options
                VStack(spacing: 20) {
                    Text("分享這個揪團")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("邀請朋友一起參加")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // QR Code display
                    VStack(spacing: 12) {
                        if showQRCode {
                            ShareQRCodeView(url: "https://juka.app/groups/\(activity.id)")
                                .frame(width: 200, height: 200)
                                .padding()
                        }
                        
                        Text("掃描 QR Code 加入揪團")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                    
                    // Sharing options
                    HStack(spacing: 24) {
                        ShareButton(title: "連結", iconName: "link", color: .blue) {
                            // Copy link
                            UIPasteboard.general.string = "https://juka.app/groups/\(activity.id)"
                            // Show toast notification
                        }
                        
                        ShareButton(title: "訊息", iconName: "message.fill", color: .green) {
                            // Open messages
                        }
                        
                        ShareButton(title: "更多", iconName: "ellipsis", color: .gray) {
                            // Open activity sheet
                        }
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("分享")
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

struct ShareQRCodeView: View {
    let url: String
    
    var body: some View {
        if let qrCode = generateQRCode(from: url) {
            Image(uiImage: qrCode)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
        } else {
            Text("無法生成 QR Code")
                .foregroundColor(.secondary)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        if let qrFilter = CIFilter(name: "CIQRCodeGenerator") {
            qrFilter.setValue(data, forKey: "inputMessage")
            qrFilter.setValue("H", forKey: "inputCorrectionLevel")
            
            if let qrImage = qrFilter.outputImage {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledQrImage = qrImage.transformed(by: transform)
                
                let context = CIContext()
                if let cgImage = context.createCGImage(scaledQrImage, from: scaledQrImage.extent) {
                    return UIImage(cgImage: cgImage)
                }
            }
        }
        return nil
    }
}

struct ShareButton: View {
    let title: String
    let iconName: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: iconName)
                            .font(.system(size: 24))
                            .foregroundColor(color)
                    )
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct MapPreview: View {
    let coordinate: CLLocationCoordinate2D
    
    var body: some View {
        Map(position: .constant(MapCameraPosition.region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
        ))) {
            Marker("", coordinate: coordinate)
                .tint(.red)
        }
    }
}

struct TimeRemainingIndicator: View {
    let expiresAt: Date?
    
    var body: some View {
        if let expiresAt = expiresAt {
            let remaining = expiresAt.timeIntervalSince(Date())
            let progress = min(max(0, remaining / 3600), 1) // Normalize to 0-1 based on an hour
            
            HStack(spacing: 4) {
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        remaining > 1800 ? Color.green : (remaining > 900 ? Color.orange : Color.red),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 16, height: 16)
                
                Text(formatTimeRemaining(until: expiresAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        } else {
            Text("無期限")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private func formatTimeRemaining(until date: Date) -> String {
        let seconds = Int(date.timeIntervalSince(Date()))
        
        if seconds < 0 {
            return "已結束"
        }
        
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)小時"
        } else {
            return "\(minutes)分鐘"
        }
    }
}

// MARK: - GroupPreviewView

struct GroupPreviewView: View {
    let activity: GroupActivity
    var onJoinPressed: () -> Void
    
    @State private var isJoining = false
    @State private var showShareSheet = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Image section with type badge (top section)
            ZStack(alignment: .bottomLeading) {
                // Activity image or gradient placeholder
                if activity.imageURL != nil {
                    AsyncImage(url: activity.imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } placeholder: {
                        activityGradientPlaceholder
                    }
                } else {
                    activityGradientPlaceholder
                }
                
                // Type badge and activity info overlay
                VStack(alignment: .leading, spacing: 8) {
                    GroupTypeBadge(type: activity.type)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    
                    Text(activity.title)
                        .font(AppStyles.Typography.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                        .lineLimit(2)
                }
                .padding(16)
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .overlay(
                // Share button (top right)
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .padding(12),
                alignment: .topTrailing
            )
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activity: activity)
            }
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("活動介紹")
                    .font(AppStyles.Typography.subtitle)
                    .foregroundColor(.primary)
                
                Text(activity.activityDescription)
                    .font(AppStyles.Typography.body)
                    .foregroundColor(.primary)
                    .lineLimit(4)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(colorScheme == .dark ? 
                                 Color(.systemGray6) : 
                                 Color(.systemGray6).opacity(0.5))
                    )
            }
            
            // Location with map
            VStack(alignment: .leading, spacing: 12) {
                Text("地點")
                    .font(AppStyles.Typography.subtitle)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                        .font(.headline)
                    
                    if let placeName = activity.location.placeName {
                        Text(placeName)
                            .font(AppStyles.Typography.body)
                    } else {
                        Text("地圖上標示的位置")
                            .font(AppStyles.Typography.body)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        openMaps(coordinate: activity.location.coordinate, name: activity.location.placeName)
                    }) {
                        Text("導航")
                            .font(AppStyles.Typography.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppStyles.primary)
                            .cornerRadius(12)
                            .shadow(color: AppStyles.primary.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                }
                
                // Map preview
                MapPreview(coordinate: activity.location.coordinate)
                    .frame(height: 160)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
            }
            
            // Time section
            VStack(alignment: .leading, spacing: 12) {
                Text("時間")
                    .font(AppStyles.Typography.subtitle)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                        .font(.headline)
                    
                    Text(timeRemainingText)
                        .font(AppStyles.Typography.body)
                    
                    Spacer()
                    
                    TimeRemainingIndicator(expiresAt: activity.expiresAt)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? 
                             Color(.systemGray6) : 
                             Color(.systemGray6).opacity(0.5))
                )
            }
            
            // User info section
            VStack(alignment: .leading, spacing: 16) {
                // Creator info
                HStack(spacing: 12) {
                    Circle()
                        .fill(AppStyles.primaryGradient)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(activity.creatorName.first ?? "?"))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                        .shadow(color: AppStyles.primary.opacity(0.3), radius: 2, x: 0, y: 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activity.creatorName)
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("活動發起者")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    participantsBadge
                }
            }
            
            // Join button
            Button(action: {
                isJoining = true
                // Simulate network request
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    isJoining = false
                    onJoinPressed()
                }
            }) {
                HStack {
                    if isJoining {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    } else {
                        Image(systemName: "person.badge.plus")
                            .font(.headline)
                            .padding(.trailing, 5)
                    }
                    
                    Text(isJoining ? "加入中..." : "立即加入揪團")
                        .font(AppStyles.Typography.button)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    isJoining 
                        ? LinearGradient(colors: [Color.gray], startPoint: .leading, endPoint: .trailing)
                        : AppStyles.primaryGradient
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(
                    color: isJoining ? Color.gray.opacity(0.3) : AppStyles.primary.opacity(0.3),
                    radius: 5,
                    x: 0,
                    y: 2
                )
                .disabled(isJoining)
            }
            .padding(.top, 8)
        }
    }
    
    private var activityGradientPlaceholder: some View {
        ZStack {
            LinearGradient(
                colors: [
                    typeColor.opacity(0.8),
                    typeColor.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)
            
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.5))
        }
    }
    
    private var participantsBadge: some View {
        VStack {
            Text("\(activity.participantIds.count + 1)")
                .font(.headline)
                .foregroundColor(AppStyles.primary)
            
            Text("位參與者")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppStyles.primary.opacity(0.1))
        )
    }
    
    private var timeRemainingText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        
        if let expiresAt = activity.expiresAt {
            if expiresAt < Date() {
                return "已結束"
            } else {
                return "還有 \(formatTimeRemaining(until: expiresAt))"
            }
        } else {
            return "無期限"
        }
    }
    
    private func formatTimeRemaining(until date: Date) -> String {
        let seconds = Int(date.timeIntervalSince(Date()))
        
        if seconds < 0 {
            return "已結束"
        }
        
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours) 小時 \(minutes) 分鐘"
        } else {
            return "\(minutes) 分鐘"
        }
    }
    
    private func openMaps(coordinate: CLLocationCoordinate2D, name: String?) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name ?? "揪咖地點"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
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
    
    private var typeColor: Color {
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
    
    GroupPreviewView(activity: activity) {
        print("Join tapped")
    }
    .padding()
} 