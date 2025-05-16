//
//  JukaApp.swift
//  Juka
//
//  Created by SandWitch on 2025/2/26.
//

import SwiftUI
import SwiftData
import Foundation

@main
struct JukaApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GroupActivity.self,
            User.self,
            Juka.ChatMessage.self,
            Location.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(authManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}

struct MainTabView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTab = 1
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ExploreView()
                .tabItem {
                    Label("探索", systemImage: "safari")
                }
                .tag(0)
            
            MapView()
                .tabItem {
                    Label("地圖", systemImage: "map")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("我的", systemImage: "person")
                }
                .tag(2)
        }
        .accentColor(AppStyles.primary)
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        .fullScreenCover(isPresented: $authManager.shouldShowTutorial) {
            TutorialView()
                .onDisappear {
                    authManager.hideTutorial()
                }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [GroupActivity.self, User.self, Juka.ChatMessage.self, Location.self], inMemory: true)
        .environmentObject(AuthenticationManager.shared)
        .environmentObject(ThemeManager.shared)
}
