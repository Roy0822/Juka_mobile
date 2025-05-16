import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.colorScheme) private var colorScheme
    @State private var isAnimationComplete = false
    @State private var showSignInButton = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var showTermsSheet = false
    @State private var showPrivacySheet = false
    
    var body: some View {
        ZStack {
            // 背景漸層
            LinearGradient(
                colors: [Color(hex: "5170FF").opacity(0.3), Color(hex: "FF66C4").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 提高對比度的半透明層
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            // 判斷是否已登入
            if authManager.isAuthenticated {
                MainTabView()
                    .transition(.opacity)
            } else {
                VStack {
                    Spacer()
                    
                    // Logo和應用名稱
                    VStack(spacing: 16) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                        
                        Text("Juka 揪咖")
                            .font(.system(size: 42, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("乞丐超人拯救世界")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    
                    Spacer()
                    
                    // 登入按鈕（動畫完成後顯示）
                    if showSignInButton {
                        VStack(spacing: 20) {
                            Button(action: {
                                authManager.signInWithGoogle()
                            }) {
                                ZStack {
                                    // 按鈕背景和內容
                                    HStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Text("G")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(Color(hex: "5170FF"))
                                            )
                                        
                                        Text("使用Google登入")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color(hex: "5170FF").opacity(0.8), Color(hex: "FF66C4").opacity(0.8)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                                    .opacity(authManager.isLoading ? 0.7 : 1)
                                    
                                    // Loading動畫覆蓋在按鈕上
                                    if authManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(1.2)
                                    }
                                }
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                                .padding(.horizontal, 40)
                            }
                            .disabled(authManager.isLoading)
                            .opacity(showSignInButton ? 1 : 0)
                            .animation(.easeIn(duration: 0.8), value: showSignInButton)
                            
                            // 服務條款和隱私政策文字，使用主題色和可點擊連結
                            HStack(spacing: 4) {
                                Text("登入即代表你同意我們的")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button("服務條款") {
                                    showTermsSheet = true
                                }
                                .font(.caption.bold())
                                .foregroundColor(Color(hex: "5170FF"))
                                
                                Text("和")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Button("隱私政策") {
                                    showPrivacySheet = true
                                }
                                .font(.caption.bold())
                                .foregroundColor(Color(hex: "FF66C4"))
                            }
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(showSignInButton ? 1 : 0)
                            .animation(.easeIn(duration: 0.8).delay(0.2), value: showSignInButton)
                        }
                        .padding(.bottom, 50)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                }
                .onAppear {
                    // 應用名稱和標誌的淡入動畫
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                    
                    // 動畫結束後，顯示登入按鈕
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            self.isAnimationComplete = true
                            self.showSignInButton = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showTermsSheet) {
            TermsView()
        }
        .sheet(isPresented: $showPrivacySheet) {
            PrivacyPolicyView()
        }
    }
}

// 服務條款視圖
struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("服務條款")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    Text("最後更新日期：2024年3月1日")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 16)
                    
                    Text("歡迎使用 Juka 揪咖！這些服務條款規定了您使用我們的應用程式和服務的條件。")
                        .font(.body)
                    
                    Group {
                        sectionTitle("1. 服務使用")
                        sectionText("Juka 揪咖提供一個平台讓用戶能夠建立、參與和管理各種線下活動。您必須年滿18歲或在您所在地區的法定成年年齡才能使用我們的服務。")
                        
                        sectionTitle("2. 用戶帳號")
                        sectionText("使用我們的服務需要創建帳號。您同意提供準確、完整和最新的信息，並對與您的帳號相關的所有活動負責。")
                        
                        sectionTitle("3. 用戶行為")
                        sectionText("使用我們的服務時，您同意不會發布非法、有害、欺詐、歧視或侵犯他人權利的內容。我們保留在我們看來必要或適當的情況下刪除內容或終止用戶使用權的權利。")
                        
                        sectionTitle("4. 安全和隱私")
                        sectionText("使用我們的服務即表示您同意我們的隱私政策，其中詳細說明了我們如何收集、使用和分享您的個人信息。")
                        
                        sectionTitle("5. 知識產權")
                        sectionText("我們的服務及其內容受版權、商標和其他知識產權法律的保護。您不得未經授權複製或分發我們的內容。")
                    }
                }
                .padding()
            }
            .navigationTitle("服務條款")
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
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(Color(hex: "5170FF"))
            .padding(.top, 16)
            .padding(.bottom, 4)
    }
    
    private func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.primary)
    }
}

// 隱私政策視圖
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("隱私政策")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    Text("最後更新日期：2024年3月1日")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 16)
                    
                    Text("Juka 揪咖致力於保護您的隱私。本隱私政策說明我們如何收集、使用、披露和保護您的個人信息。")
                        .font(.body)
                    
                    Group {
                        sectionTitle("1. 我們收集的信息")
                        sectionText("我們收集您提供給我們的信息，如姓名、電子郵件地址、位置數據和用戶偏好。我們也會收集您與我們的應用程式互動時自動生成的信息。")
                        
                        sectionTitle("2. 信息的使用")
                        sectionText("我們使用收集到的信息來提供、維護和改進我們的服務，並為您提供個性化的體驗。我們也可能使用這些信息來與您溝通、發送通知和營銷信息。")
                        
                        sectionTitle("3. 信息的分享")
                        sectionText("我們不會出售或出租您的個人信息給第三方。我們可能會與服務提供商分享信息，他們幫助我們運營我們的服務，但他們只能按照我們的指示處理您的信息。")
                        
                        sectionTitle("4. 位置數據")
                        sectionText("我們的應用程式使用位置數據來為您提供附近的活動信息。您可以隨時在設備設置中控制位置權限。")
                        
                        sectionTitle("5. 您的權利")
                        sectionText("您有權訪問、更正或刪除您的個人信息。您也可以隨時選擇退出我們的營銷通信。")
                    }
                }
                .padding()
            }
            .navigationTitle("隱私政策")
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
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(Color(hex: "FF66C4"))
            .padding(.top, 16)
            .padding(.bottom, 4)
    }
    
    private func sectionText(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.primary)
    }
}

#Preview {
    SplashView()
        .environmentObject(ThemeManager.shared)
        .environmentObject(AuthenticationManager.shared)
} 
