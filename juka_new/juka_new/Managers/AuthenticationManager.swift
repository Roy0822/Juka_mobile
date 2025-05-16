import SwiftUI

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var currentUser: User?
    @Published var shouldShowTutorial = false
    @Published var shouldShowRingSelection = false
    @Published var selectedRingIndex: Int = 0
    
    private init() {
        // 在實際應用中，這裡會檢查持久性存儲中的驗證狀態
        // 這裡簡化為假設用戶未登入
        self.isAuthenticated = false
        self.shouldShowTutorial = !UserDefaults.standard.bool(forKey: "completedTutorial")
        self.selectedRingIndex = UserDefaults.standard.integer(forKey: "selectedRingIndex")
    }
    
    func signInWithGoogle() {
        isLoading = true
        
        // 模擬網絡請求的延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // 創建模擬用戶
            let mockUser = User(
                id: "user_\(UUID().uuidString)",
                name: "示範用戶",
                email: "demo@example.com",
                profileImageURL: nil
            )
            
            self.currentUser = mockUser
            self.isAuthenticated = true
            self.isLoading = false
            
            // 顯示戒指選擇介面
            self.shouldShowRingSelection = true
            
            // 如果是第一次登入，稍後會顯示教學導覽
            if !UserDefaults.standard.bool(forKey: "completedTutorial") {
                self.shouldShowTutorial = true
            }
        }
    }
    
    func signOut() {
        isLoading = true
        
        // 模擬網絡請求的延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentUser = nil
            self.isAuthenticated = false
            self.isLoading = false
        }
    }
    
    func hideTutorial() {
        shouldShowTutorial = false
        UserDefaults.standard.set(true, forKey: "completedTutorial")
    }
    
    func selectRing(index: Int) {
        selectedRingIndex = index
        UserDefaults.standard.set(index, forKey: "selectedRingIndex")
        shouldShowRingSelection = false
    }
    
    func skipRingSelection() {
        shouldShowRingSelection = false
    }
} 