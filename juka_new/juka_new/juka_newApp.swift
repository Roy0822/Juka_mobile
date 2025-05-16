//
//  juka_newApp.swift
//  juka_new
//
//  Created by kevin Chou on 2025/4/24.
//

import SwiftUI
import SwiftData

@main
struct juka_newApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GroupActivity.self,
            User.self,
            ChatMessage.self,
            Location.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("無法創建ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(authManager)
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
