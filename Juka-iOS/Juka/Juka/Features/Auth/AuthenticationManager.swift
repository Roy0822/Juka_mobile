import SwiftUI
import Foundation

// This is a placeholder for actual Google OAuth implementation
// In a real app, you would use GoogleSignIn SDK
class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    @Published var shouldShowTutorial = false
    
    private let userPrefs = UserPreferencesManager()
    
    static let shared = AuthenticationManager()
    
    private init() {}
    
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // This would be replaced with actual Google Sign-In SDK code
            // In production, you'd integrate with GoogleSignIn and handle the auth flow
            
            self.isLoading = false
            
            // Create a mock user for demo purposes
            self.currentUser = User(
                id: "google-user-123",
                name: "Google User",
                profileImageURL: nil,
                preferences: [.coffeeDeal, .foodDeal]
            )
            
            self.isAuthenticated = true
            
            // 目前暫時每次登入都顯示教學頁面（後續可根據 UserDefaults 判斷是否首次登入）
            self.shouldShowTutorial = true
        }
    }
    
    func signOut() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
            self.isAuthenticated = false
            self.currentUser = nil
            self.shouldShowTutorial = false
        }
    }
    
    func hideTutorial() {
        shouldShowTutorial = false
    }
    
    func showTutorialAgain() {
        shouldShowTutorial = true
    }
} 