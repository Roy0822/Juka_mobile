import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                MainTabView()
            } else {
                loginContent
            }
        }
    }
    
    private var loginContent: some View {
        ZStack {
            // Background
            AppStyles.background
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo and app name
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 70))
                        .foregroundColor(AppStyles.primary)
                    
                    Text("Juka 揪咖")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(AppStyles.primary)
                    
                    Text("乞丐超人拯救世界")
                        .font(.system(size: 18))
                        .foregroundColor(AppStyles.secondaryLabel)
                }
                
                Spacer()
                
                // Description
                VStack(spacing: 24) {
                    descriptionRow(icon: "person.2.fill", text: "人多力量大")
                    descriptionRow(icon: "tag.fill", text: "探索附近的優惠與共享")
                    descriptionRow(icon: "mappin.circle.fill", text: "與乞丐超人們一起揪團打龍")
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Sign in button
                VStack(spacing: 20) {
                    Button(action: {
                        authManager.signInWithGoogle()
                    }) {
                        HStack {
                            Circle()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.white)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("G")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppStyles.label)
                                )
                            
                            Text("使用Google登入")
                                .font(.headline)
                                .foregroundColor(AppStyles.label)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppStyles.tertiaryBackground)
                        .cornerRadius(AppStyles.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppStyles.cornerRadius)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .disabled(authManager.isLoading)
                    
                    if authManager.isLoading {
                        ProgressView()
                            .padding(.top, 10)
                    }
                    
                    if let errorMessage = authManager.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }
                    
                    Text("登入即代表你同意我們的服務條款和隱私政策")
                        .font(.caption)
                        .foregroundColor(AppStyles.secondaryLabel)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.horizontal, 32)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func descriptionRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppStyles.primary)
                .frame(width: 32, height: 32)
            
            Text(text)
                .font(.body)
                .foregroundColor(AppStyles.label)
            
            Spacer()
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(ThemeManager.shared)
} 
