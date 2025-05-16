//
//  ContentView.swift
//  juka_new
//
//  Created by kevin Chou on 2025/4/24.
//

import SwiftUI
import SwiftData

// Define accent colors directly
let accentColor1 = Color(red: 1.0, green: 107/255, blue: 149/255) // FF6B95
let accentColor2 = Color(red: 1.0, green: 151/255, blue: 119/255) // FF9777
let actionGradient = LinearGradient(colors: [accentColor1, accentColor2], startPoint: .topLeading, endPoint: .bottomTrailing)

// 定義一個通知名稱用於隱藏鍵盤
extension Notification.Name {
    static let dismissKeyboard = Notification.Name("dismissKeyboard")
}

struct ContentView: View {
    @State private var selectedTab = 1
    // REMOVED themeManager
    // @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ZStack {
            // TabView is now the base layer, covering the whole screen
                TabView(selection: $selectedTab) {
                    ExploreView()
                        .tag(0)
                    
                    MapView()
                        .tag(1)
                    
                    ProfileView()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            // Ignore all safe areas for the TabView content
            .ignoresSafeArea()
                
            // VStack to align the CustomTabBar at the bottom
            VStack {
                Spacer() // Pushes the TabBar down
                CustomTabBar(selectedTab: $selectedTab)
            }
            // Don't ignore safe area for the VStack itself, 
            // so the TabBar respects the bottom safe area
            
        }
        // No longer need to ignore safe area here as TabView handles it
        // .ignoresSafeArea(edges: .top)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabButton(title: "探索", icon: "sparkles", isSelected: selectedTab == 0) {
                // 切換標籤前發送隱藏鍵盤通知
                NotificationCenter.default.post(name: .dismissKeyboard, object: nil)
                selectedTab = 0
            }
            
            TabButton(title: "地圖", icon: "map.fill", isSelected: selectedTab == 1) {
                // 切換標籤前發送隱藏鍵盤通知
                NotificationCenter.default.post(name: .dismissKeyboard, object: nil)
                selectedTab = 1
            }
            
            TabButton(title: "我的", icon: "person.fill", isSelected: selectedTab == 2) {
                // 切換標籤前發送隱藏鍵盤通知
                NotificationCenter.default.post(name: .dismissKeyboard, object: nil)
                selectedTab = 2
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 30)
                // Use standard system background material
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.15), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(actionGradient)
                            .frame(width: 40, height: 40)
                            .shadow(color: accentColor1.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? accentColor1 : .gray) // Use accent color for selected text
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct ExploreView: View {
    // 使用與 MapView 相同的資料源
    @State private var activities: [GroupActivity] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Text("熱門揪團")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.primary) // Standard primary text
                    
                    Spacer()
                    
                    Text("查看全部")
                        .font(.system(size: 14))
                        .foregroundColor(accentColor1) // Use defined accent color
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        // 使用真實資料
                        ForEach(activities) { activity in
                            ActivityCard(activity: activity)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                
                HStack {
                    Text("揪團類型")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    CategoryItem(icon: "cup.and.saucer.fill", title: "咖啡")
                    CategoryItem(icon: "fork.knife", title: "美食")
                    CategoryItem(icon: "car.fill", title: "共乘")
                    CategoryItem(icon: "bag.fill", title: "購物")
                    CategoryItem(icon: "gamecontroller.fill", title: "娛樂")
                    CategoryItem(icon: "ellipsis.circle.fill", title: "更多")
                }
                .padding(.horizontal, 16)
                
                HStack {
                    Text("附近的揪團")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 24)
                
                VStack(spacing: 16) {
                    // 使用真實資料顯示附近的揪團
                    // 限制顯示3個
                    ForEach(activities.prefix(3), id: \.id) { activity in
                        NearbyActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 80)
            }
        }
        // Add a background to ExploreView if needed, e.g., system background
        .background(Color(.systemBackground))
        .onAppear {
            // 初始化時從JSON讀取活動資料
            activities = MockDataLoader.shared.loadMockActivities()
        }
    }
}

struct ActivityCard: View {
    let activity: GroupActivity
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground)) // Use secondary system background
                .frame(width: 200, height: 250)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.tertiarySystemBackground)) // Use tertiary system background
                        .frame(height: 120)
                    
                    Image(systemName: activity.type.icon)
                        .font(.system(size: 40))
                        .foregroundColor(accentColor1)
                        .padding(30)
                    
                    Text("限時優惠")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(accentColor1)
                        .cornerRadius(8)
                        .padding(8)
                }
                
                Text(activity.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.primary)
                
                Text(activity.activityDescription)
                    .font(.system(size: 12))
                    .foregroundColor(Color.secondary) // Use Color.secondary
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(accentColor1)
                        .font(.system(size: 12))
                    
                    Text(activity.location.placeName ?? "未知位置")
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary) // Use Color.secondary
                    
                    Spacer()
                    
                    Text("500m")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(accentColor2)
                }
            }
            .padding(12)
            .frame(width: 200)
        }
    }
}

struct CategoryItem: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    // Use a light gradient or solid color
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .gray.opacity(0.08), radius: 4, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(accentColor2)
            }
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(Color.primary)
                .padding(.top, 8)
        }
    }
}

struct NearbyActivityCard: View {
    let activity: GroupActivity
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 50, height: 50)
                    .shadow(color: .gray.opacity(0.08), radius: 3, x: 0, y: 1)

                Image(systemName: activity.type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(accentColor1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.primary)
                
                Text(activity.activityDescription)
                    .font(.system(size: 14))
                    .foregroundColor(Color.secondary) // Use Color.secondary
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(accentColor1)
                        .font(.system(size: 12))
                    
                    Text(activity.creatorName)
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary) // Use Color.secondary
                    
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(accentColor1)
                        .font(.system(size: 12))
                    
                    Text("300m")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(accentColor2)
                }
            }
            
            Spacer()
            
            Button(action: {}) {
                Text("加入")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(actionGradient)
                    .cornerRadius(16)
                    .shadow(color: accentColor1.opacity(0.2), radius: 4, x: 0, y: 2)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground)) // Use system background for the card itself
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    ContentView()
       // REMOVED themeManager environment object
       // .environmentObject(ThemeManager.shared)
}
