import SwiftUI
import WebKit

struct SplineAnimationView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        
        // 配置webView以忽略安全區域
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // 加載Spline動畫URL
        if let url = URL(string: "https://my.spline.design/claritystream-8bhSE0uscifvl8w0MqjIoBIb/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

struct FullScreenBackground<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                content
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .edgesIgnoringSafeArea(.all)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SplashScreen: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var showSignInButton = false
    @State private var showOverlay = true // 控制覆蓋層顯示
    @State private var revealScale: CGFloat = 0.001 // 控制圓形揭示的尺寸
    
    var body: some View {
        ZStack {
            if authManager.isAuthenticated {
                ContentView()
                    .transition(.opacity)
            } else {
                        ZStack {
                    // 真正全螢幕的Spline 3D動畫
                    FullScreenBackground {
                        SplineAnimationView()
                        }
                    .edgesIgnoringSafeArea(.all)
                    
                    // 只顯示登入按鈕
                    VStack {
                    Spacer()
                    
                    if showSignInButton {
                        VStack(spacing: 20) {
                            Button(action: {
                                authManager.signInWithGoogle()
                            }) {
                                ZStack {
                                    HStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 24, height: 24)
                                            .overlay(
                                                Text("G")
                                                    .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(accentColor1)
                                            )
                                        
                                        Text("使用Google登入")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                            ZStack {
                                                // 更強的霧化效果
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(.ultraThinMaterial)
                                                
                                                // 粉橘色漸層邊框
                                        RoundedRectangle(cornerRadius: 16)
                                                    .strokeBorder(
                                                LinearGradient(
                                                            colors: [accentColor1, accentColor2],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        ),
                                                        lineWidth: 2
                                            )
                                                
                                                // 內部微光效果
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                                    .blur(radius: 1)
                                                    .padding(2)
                                            }
                                    )
                                    .opacity(authManager.isLoading ? 0.7 : 1)
                                        .shadow(color: accentColor1.opacity(0.3), radius: 15, x: 0, y: 8)
                                    
                                    if authManager.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                            .scaleEffect(1.2)
                                    }
                                }
                                .padding(.horizontal, 40)
                            }
                            .disabled(authManager.isLoading)
                            .opacity(showSignInButton ? 1 : 0)
                            .animation(.easeIn(duration: 0.8), value: showSignInButton)
                            
                            HStack(spacing: 4) {
                                Text("登入即代表你同意我們的")
                                    .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.8))
                                
                                    Button("服務條款") { /* 動作 */ }
                                .font(.caption.bold())
                                    .foregroundColor(accentColor1)
                                
                                Text("和")
                                    .font(.caption)
                                        .foregroundColor(Color.white.opacity(0.8))
                                
                                    Button("隱私政策") { /* 動作 */ }
                                .font(.caption.bold())
                                    .foregroundColor(accentColor2)
                            }
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(showSignInButton ? 1 : 0)
                            .animation(.easeIn(duration: 0.8).delay(0.2), value: showSignInButton)
                        }
                        .padding(.bottom, 50)
                            .padding(.bottom, 40)
                        }
                    }
                    
                    // 黑色覆蓋層，使用圓形遮罩揭示底層內容
                    if showOverlay {
                        CircleRevealOverlay(revealScale: revealScale)
                            .edgesIgnoringSafeArea(.all)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    // 為Spline加載提供足夠時間
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                        // 啟動圓形揭示動畫
                        withAnimation(.easeInOut(duration: 1.2)) {
                            revealScale = 8.0 // 放大到足以覆蓋整個螢幕
                        }
                        
                        // 完成揭示動畫後隱藏覆蓋層
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            showOverlay = false
                            
                            // 然後顯示登入按鈕
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                                    showSignInButton = true
                                }
                            }
                        }
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $authManager.shouldShowRingSelection) {
            RingSelectionView()
        }
        .fullScreenCover(isPresented: $authManager.shouldShowTutorial) {
            TutorialView()
        }
    }
}

// 圓形揭示覆蓋層
struct CircleRevealOverlay: View {
    var revealScale: CGFloat // 控制揭示圓的尺寸
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 黑色背景
                Color.black
                
                // 圓形遮罩揭示窗口
                Circle()
                    .scale(revealScale)
                    .blendMode(.destinationOut)
            }
            .compositingGroup()
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

struct TutorialView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var currentPage = 0
    
    let tutorialSteps = [
        (icon: "map.fill", title: "探索附近揪團", description: "在地圖上查看周圍的揪團機會，找到與您興趣相符的活動"),
        (icon: "person.3.fill", title: "加入或建立揪團", description: "找到感興趣的活動後，點擊加入！或者自己建立新揪團"),
        (icon: "bubble.left.and.bubble.right.fill", title: "即時聊天", description: "與揪團成員即時溝通，討論活動細節"),
        (icon: "hand.thumbsup.fill", title: "即刻開始體驗！", description: "恭喜您完成教學！現在就開始探索附近的揪團，認識新朋友")
    ]
    
    var body: some View {
        ZStack {
            // Use standard background
            Color(.systemBackground)
            .ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    
                    if currentPage < tutorialSteps.count - 1 {
                        Button("跳過") {
                            authManager.hideTutorial()
                        }
                        .foregroundColor(Color.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.1))
                        )
                        .padding()
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(actionGradient.opacity(0.8))
                        .frame(width: 160, height: 160)
                        .shadow(color: accentColor1.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    Image(systemName: tutorialSteps[currentPage].icon)
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                VStack(spacing: 20) {
                    Text(tutorialSteps[currentPage].title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(tutorialSteps[currentPage].description)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.secondary.opacity(0.9))
                        .padding(.horizontal, 32)
                        .frame(height: 60)
                }
                .frame(height: 120)
                .padding(.bottom, 20)
                
                Spacer()
                
                HStack(spacing: 12) {
                    ForEach(0..<tutorialSteps.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.primary : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.bottom, 30)
                
                Button(action: {
                    withAnimation {
                        if currentPage < tutorialSteps.count - 1 {
                            currentPage += 1
                        } else {
                            authManager.hideTutorial()
                        }
                    }
                }) {
                    Text(currentPage < tutorialSteps.count - 1 ? "繼續" : "開始使用")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(actionGradient)
                        )
                        .shadow(color: accentColor1.opacity(0.3), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < -50 && currentPage < tutorialSteps.count - 1 {
                        withAnimation { currentPage += 1 }
                    } else if value.translation.width > 50 && currentPage > 0 {
                        withAnimation { currentPage -= 1 }
                    }
                }
        )
    }
} 