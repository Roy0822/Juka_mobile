import SwiftUI
import WebKit

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @State private var selectedTab = 0
    @State private var showSettingsSheet = false
    
    // 戒指升級進度(示例數據)
    @State private var completedOrders = 3
    @State private var requiredOrders = 5
    @State private var currentRingLevel = 2
    @State private var maxRingLevel = 5
    
    // 拖動相關狀態 - 使用枚舉定義卡片狀態
    enum CardPosition {
        case collapsed   // 收起
        case expanded    // 展開
    }
    
    @State private var cardPosition: CardPosition = .collapsed
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    // 戒指URL
    private let ringURLs: [String] = [
        "https://my.spline.design/ring2-4GUFZ0z6yPVxyB1cV3H3XMSU/",
        "https://my.spline.design/ringswithinteractivedisplacementtexturecopy-LohNRUF5rW1ErwMTdQCkVW6X/",
        "https://my.spline.design/ring1copycopy-gKSZvT46xNPgIVCfazizXShK/",
        "https://my.spline.design/ring1copycopy-CmuebjTIDPbOjhYsFsYo8SgY/"
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 黑色背景
                Color(hexString: "161616").edgesIgnoringSafeArea(.all)
                
                // 3D戒指場景 - 調整Y軸偏移量使戒指更往上
                ProfileRingView(ringIndex: authManager.selectedRingIndex, ringURL: ringURLs[authManager.selectedRingIndex], screenSize: UIScreen.main.bounds.size)
                    .edgesIgnoringSafeArea(.all)
                    .offset(y: 50) // 加入正值的Y軸偏移量，將戒指場景往下移動
                
                VStack(spacing: 0) {
                    // 頂部固定區域 - 使用ZStack確保固定在頂部
                    ZStack(alignment: .top) {
                        // 半透明背景以確保文字清晰可見
                        Rectangle()
                            .fill(Color(hexString: "161616").opacity(0.7))
                            .frame(height: 60 + getSafeAreaInsets().top) // 包含安全區域高度
                            .edgesIgnoringSafeArea(.top)
                        
                        VStack(spacing: 0) {
                            HStack {
                                // 用戶等級和戒指名稱
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("LV. \(calculateLevel())")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text(getRingName())
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(Color(hexString: getRingColor()))
                                }
                                .padding(.leading, 20)
                                
                                Spacer()
                                
                                // 設定按鈕
                                Button(action: {
                                    showSettingsSheet = true
                                }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                }
                                .padding(.trailing, 20)
                            }
                            .frame(height: 60)
                        }
                        .padding(.top, getSafeAreaInsets().top) // 正好貼著安全區域頂部
                    }
                    .frame(height: 60 + getSafeAreaInsets().top)
                    .zIndex(2) // 確保頂部欄永遠在最上層
                    
                    Spacer()
                }
                
                // 可拖曳的卡片視圖
                ProfileCardView(
                    cardPosition: $cardPosition,
                    isDragging: $isDragging,
                    dragOffset: $dragOffset,
                    selectedTab: $selectedTab,
                    completedOrders: completedOrders,
                    requiredOrders: requiredOrders,
                    geometry: geometry
                )
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            SettingsView()
                .presentationDetents([.medium, .large])
        }
    }
    
    // 獲取戒指對應的圖標
    private func getRingIcon(index: Int) -> Image {
        switch index {
        case 0:
            return Image(systemName: "drop.fill") // 翠流之戒 - 水滴
        case 1:
            return Image(systemName: "wind") // 薰育之戒 - 風
        case 2:
            return Image(systemName: "sun.max.fill") // 橙心之戒 - 太陽
        case 3:
            return Image(systemName: "flame.fill") // 赤光之戒 - 火焰
        default:
            return Image(systemName: "person.fill")
        }
    }
    
    // 獲取戒指名稱
    private func getRingName() -> String {
        switch authManager.selectedRingIndex {
        case 0:
            return "翠流之戒"
        case 1:
            return "薰育之戒"
        case 2:
            return "橙心之戒"
        case 3:
            return "赤光之戒"
        default:
            return "初階戒指"
        }
    }
    
    // 計算當前等級
    private func calculateLevel() -> Int {
        return currentRingLevel
    }
    
    // 獲取戒指顏色
    private func getRingColor() -> String {
        switch authManager.selectedRingIndex {
        case 0: // 翠流之戒 - 綠色
            return "00C9A7"
        case 1: // 薰育之戒 - 紫色
            return "845EC2"
        case 2: // 橙心之戒 - 橙色
            return "FF9671"
        case 3: // 赤光之戒 - 紅色
            return "FF5E78"
        default:
            return "FF6B95" // 預設粉紅色（accentColor1）
        }
    }
    
    // 獲取戒指對應的頭銜
    private func getRingTitle(index: Int, level: Int) -> String {
        let titles: [[String]] = [
            // 翠流之戒頭銜
            ["水滴初心者", "溪流導向者", "河川護衛者", "海洋策劃師", "翠流主宰"],
            // 薰育之戒頭銜
            ["微風使者", "薰風策劃師", "旋風操控者", "氣流領航員", "風暴主宰"],
            // 橙心之戒頭銜
            ["暖陽新手", "晴空策劃師", "曙光開拓者", "日華守護者", "橙心主宰"],
            // 赤光之戒頭銜
            ["星火使者", "熾焰策劃師", "烈火操控者", "焰心領航員", "赤光主宰"]
        ]
        
        let levelIndex = min(max(0, level - 1), 4) // 確保等級在1-5之間
        let titleIndex = min(max(0, index), 3) // 確保戒指索引在0-3之間
        
        return titles[titleIndex][levelIndex]
    }
    
    // 獲取戒指對應的漸層顏色
    private func getGradientForRing(index: Int) -> LinearGradient {
        switch index {
        case 0: // 翠流之戒 - 綠色漸層
            return LinearGradient(
                colors: [Color(hexString: "00C9A7"), Color(hexString: "128760")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 1: // 薰育之戒 - 紫色漸層
            return LinearGradient(
                colors: [Color(hexString: "845EC2"), Color(hexString: "4B4453")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2: // 橙心之戒 - 橙色漸層
            return LinearGradient(
                colors: [Color(hexString: "FF9671"), Color(hexString: "C34A36")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 3: // 赤光之戒 - 紅色漸層
            return LinearGradient(
                colors: [Color(hexString: "FF5E78"), Color(hexString: "B91E46")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return actionGradient
        }
    }
    
    // 獲取安全區域邊距的函數
    private func getSafeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0) // 預設值
        }
        
        return window.safeAreaInsets
    }
}

// 新的卡片視圖元件，負責處理拖曳和顯示
struct ProfileCardView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Binding var cardPosition: ProfileView.CardPosition
    @Binding var isDragging: Bool
    @Binding var dragOffset: CGFloat
    @Binding var selectedTab: Int
    
    let completedOrders: Int
    let requiredOrders: Int
    let geometry: GeometryProxy
    
    // 手勢識別器
    private let dragThreshold: CGFloat = 60
    
    // 計算卡片位置
    private var cardYOffset: CGFloat {
        let collapsedPosition = geometry.size.height * 0.45 // 收起狀態的位置
        let expandedPosition = geometry.size.height * 0.10 // 從0.15改為0.10，使展開時佔滿90%高度
        
        switch cardPosition {
        case .collapsed:
            return collapsedPosition + dragOffset
        case .expanded:
            return expandedPosition + dragOffset
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 拖曳手柄區域
            VStack(spacing: 8) {
                // 上方的拖動指示器
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                
                // 用戶名
                Text(authManager.currentUser?.name ?? "用戶")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color.primary)
                
                // 評分星星
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(authManager.currentUser?.rating ?? 5) ? "star.fill" : "star")
                            .foregroundColor(accentColor2)
                    }
                    
                    Text(String(format: "%.1f", authManager.currentUser?.rating ?? 5.0))
                        .font(.system(size: 14))
                        .foregroundColor(Color.primary)
                        .padding(.leading, 4)
                }
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground).opacity(0.01)) // 透明背景確保整個區域可點擊
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            // 開始拖拽時的額外處理
                            isDragging = true
                        }
                        
                        // 直接設置拖拽偏移量，不添加任何阻尼效果
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        // 拖拽結束時的行為
                        let velocity = value.predictedEndTranslation.height / max(1, abs(value.translation.height))
                        let dragAmount = value.translation.height
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            if cardPosition == .collapsed {
                                // 當前收起狀態
                                if dragAmount < -dragThreshold || (velocity < -1 && dragAmount < 0) {
                                    // 向上滑動超過閾值或有足夠向上速度，展開卡片
                                    cardPosition = .expanded
                                }
                            } else {
                                // 當前展開狀態
                                if dragAmount > dragThreshold || (velocity > 1 && dragAmount > 0) {
                                    // 向下滑動超過閾值或有足夠向下速度，收起卡片
                                    cardPosition = .collapsed
                                }
                            }
                            
                            // 重置拖拽偏移量
                            dragOffset = 0
                            isDragging = false
                        }
                    }
            )
            // 點擊手勢：點擊可切換卡片狀態
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    cardPosition = cardPosition == .collapsed ? .expanded : .collapsed
                }
            }
            
            // 卡片內容
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // 升級進度信息
                    HStack {
                        Text("揪團完成度")
                            .font(.system(size: 14))
                            .foregroundColor(Color.secondary)
                        
                        Spacer()
                        
                        Text("\(completedOrders)/\(requiredOrders)次升級")
                            .font(.system(size: 14))
                            .foregroundColor(Color.secondary)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 5)
                    
                    // 進度條
                    ProgressView(value: Double(completedOrders), total: Double(requiredOrders))
                        .progressViewStyle(RingProgressStyle(ringIndex: authManager.selectedRingIndex))
                        .frame(height: 10)
                        .padding(.horizontal, 30)
                    
                    // 分頁選擇按鈕
                    HStack(spacing: 0) {
                        ProfileTabButton(title: "我的揪團", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        ProfileTabButton(title: "我的收藏", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(.secondarySystemBackground).opacity(0.5))
                    )
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
            
                    // TabView內容
                    if selectedTab == 0 {
                        MyGroupsTab()
                            .padding(.bottom, 100)
                    } else {
                        FavoritesTab()
                            .padding(.bottom, 100)
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, getSafeAreaInsets().bottom + 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(.systemBackground))
        )
        .offset(y: cardYOffset)
        .onChange(of: cardPosition) { newValue in
            // 只在卡片狀態切換時提供觸覺反饋，而不是在拖動時
            if !isDragging {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
        }
        // 確保僅在非拖動狀態下應用動畫
        .animation(isDragging ? nil : .spring(response: 0.3, dampingFraction: 0.7), value: cardPosition)
        // 不為拖動偏移量添加額外的動畫效果
        .animation(nil, value: dragOffset)
    }
    
    // 獲取安全區域邊距的函數
    private func getSafeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIEdgeInsets(top: 47, left: 0, bottom: 34, right: 0) // 預設值
        }
        
        return window.safeAreaInsets
    }
}

// 3D戒指顯示視圖
struct ProfileRingView: UIViewRepresentable {
    let ringIndex: Int
    let ringURL: String
    let screenSize: CGSize
    
    // Spline場景的原始長寬比
    private let splineAspectRatio: CGFloat = 758.0 / 1372.0
    
    func makeUIView(context: Context) -> UIView {
        // 創建一個容器視圖
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1.0) // #161616
        
        // 計算最佳尺寸
        let optimalSize = calculateOptimalSize(for: screenSize)
        
        // 創建WebView的配置
        let config = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 添加初始樣式設置腳本 - 在HTML載入前立即執行
        let initialStyleScript = """
        var initialStyle = document.createElement('style');
        initialStyle.textContent = `
            html, body, canvas, .spline-viewer, #canvas3d, iframe {
                width: 100% !important;
                height: 100% !important;
                margin: 0 !important;
                padding: 0 !important;
                overflow: hidden !important;
                background-color: #161616 !important;
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
            }
            canvas {
                transform: translateY(-20%) !important;
            }
        `;
        document.head.appendChild(initialStyle);
        """
        let initialUserScript = WKUserScript(source: initialStyleScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(initialUserScript)
        
        // 添加預加載腳本以確保立即顯示在正確位置
        let preloadScript = """
        // 在文檔開始加載時就執行
        (function() {
            // 立即設置背景色
            document.documentElement.style.backgroundColor = '#161616';
            document.body.style.backgroundColor = '#161616';
            
            // 創建並立即注入初始樣式
            var style = document.createElement('style');
            style.id = 'initial-spline-styles';
            style.textContent = `
                html, body, canvas, .spline-viewer, #canvas3d, iframe {
                    width: 100% !important;
                    height: 100% !important;
                    margin: 0 !important;
                    padding: 0 !important;
                    overflow: hidden !important;
                    background-color: #161616 !important;
                    position: fixed !important;
                    top: 0 !important;
                    left: 0 !important;
                }
                canvas {
                    transform: translateY(-20%) !important;
                }
            `;
            document.head.appendChild(style);
            
            // 優化性能：使用requestAnimationFrame而不是定時器
            var pendingUpdate = false;
            function scheduleUpdate() {
                if (!pendingUpdate) {
                    pendingUpdate = true;
                    requestAnimationFrame(function() {
                        enforceStyles();
                        pendingUpdate = false;
                    });
                }
            }
            
            // 監控DOM變化，確保我們的設置不被覆蓋
            var observer = new MutationObserver(function(mutations) {
                scheduleUpdate();
            });
            
            // 開始觀察DOM變化
            observer.observe(document.documentElement, {
                childList: true,
                subtree: true,
                attributes: true
            });
            
            function enforceStyles() {
                // 立即設置背景色
                document.documentElement.style.backgroundColor = '#161616';
                document.body.style.backgroundColor = '#161616';
                
                // 確保我們的樣式存在
                if (!document.getElementById('initial-spline-styles')) {
                    document.head.appendChild(style);
                }
                
                // 強制應用樣式到關鍵元素
                var canvas = document.querySelector('canvas');
                if (canvas) {
                    canvas.style.position = 'fixed';
                    canvas.style.top = '0';
                    canvas.style.left = '0';
                    canvas.style.width = '100%';
                    canvas.style.height = '100%';
                    canvas.style.transform = 'translateY(-20%)';
                    canvas.style.backgroundColor = '#161616';
                }
                
                var splineViewer = document.querySelector('.spline-viewer');
                if (splineViewer) {
                    splineViewer.style.position = 'fixed';
                    splineViewer.style.top = '0';
                    splineViewer.style.left = '0';
                    splineViewer.style.width = '100%';
                    splineViewer.style.height = '100%';
                    splineViewer.style.backgroundColor = '#161616';
                }
                
                var canvas3d = document.getElementById('canvas3d');
                if (canvas3d) {
                    canvas3d.style.position = 'fixed';
                    canvas3d.style.top = '0';
                    canvas3d.style.left = '0';
                    canvas3d.style.width = '100%';
                    canvas3d.style.height = '100%';
                    canvas3d.style.backgroundColor = '#161616';
                }
            }
            
            // 立即執行一次
            enforceStyles();
            
            // 只在關鍵時刻檢查，而不是持續輪詢，減少計算負擔
            window.addEventListener('resize', scheduleUpdate);
            document.addEventListener('DOMContentLoaded', function() {
                enforceStyles();
                try {
                    window.webkit.messageHandlers.loadCompleted.postMessage("domLoaded");
                } catch(e) {}
            });
            
            window.addEventListener('load', function() {
                enforceStyles();
                try {
                    window.webkit.messageHandlers.loadCompleted.postMessage("windowLoaded");
                } catch(e) {}
                
                // 加載後一秒再檢查一次，確保所有元素位置正確
                setTimeout(enforceStyles, 1000);
            });
        })();
        """
        let preloadUserScript = WKUserScript(source: preloadScript, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        userContentController.addUserScript(preloadUserScript)
        
        // 添加訊息處理
        userContentController.add(context.coordinator, name: "loadCompleted")
        
        config.userContentController = userContentController
        
        // 必要的偏好設置以確保模型能夠正確運行
        config.preferences.javaScriptEnabled = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // 創建WebView - 啟用快速加載優化
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: optimalSize.width, height: optimalSize.height), configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1.0)
        webView.scrollView.backgroundColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1.0)
        
        // 啟用內容模式提示以加速渲染
        webView.layer.contentsFormat = .RGBA8Uint
        webView.layer.isOpaque = true
        webView.layer.drawsAsynchronously = true
        
        // 一開始隱藏WebView，等加載完成再顯示
        webView.alpha = 0.0
        
        // 設置導航代理
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // 配置WebView以忽略安全區域
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // 加載Spline場景URL之前確保設置用戶代理
        if let url = URL(string: ringURL) {
            var request = URLRequest(url: url)
            request.cachePolicy = .returnCacheDataElseLoad // 嘗試使用緩存提高加載速度
            request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
            webView.load(request)
        }
        
        // 將WebView添加到容器並進行適當居中定位
        containerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // 設置約束以確保正確居中和尺寸
        NSLayoutConstraint.activate([
            webView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            webView.widthAnchor.constraint(equalToConstant: optimalSize.width),
            webView.heightAnchor.constraint(equalToConstant: optimalSize.height)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 取得WebView
        guard let webView = uiView.subviews.first as? WKWebView else { return }
        
        // 計算最佳尺寸
        let optimalSize = calculateOptimalSize(for: screenSize)
        
        // 更新WebView的尺寸
        for constraint in webView.constraints {
            if constraint.firstAttribute == .width {
                constraint.constant = optimalSize.width
            } else if constraint.firstAttribute == .height {
                constraint.constant = optimalSize.height
            }
        }
        
        // 強制執行腳本確保位置正確
        let positionFixScript = """
        (function() {
            document.documentElement.style.backgroundColor = '#161616';
            document.body.style.backgroundColor = '#161616';
            
            var canvas = document.querySelector('canvas');
            if (canvas) {
                canvas.style.position = 'fixed';
                canvas.style.top = '0';
                canvas.style.left = '0';
                canvas.style.width = '100%'; 
                canvas.style.height = '100%';
                canvas.style.transform = 'translateY(-20%)';
                canvas.style.backgroundColor = '#161616';
                canvas.style.objectFit = 'contain';
            }
            
            var splineViewer = document.querySelector('.spline-viewer');
            if (splineViewer) {
                splineViewer.style.position = 'fixed';
                splineViewer.style.top = '0';
                splineViewer.style.left = '0';
                splineViewer.style.width = '100%';
                splineViewer.style.height = '100%';
                splineViewer.style.backgroundColor = '#161616';
            }
            
            var canvas3d = document.getElementById('canvas3d');
            if (canvas3d) {
                canvas3d.style.position = 'fixed';
                canvas3d.style.top = '0';
                canvas3d.style.left = '0';
                canvas3d.style.width = '100%';
                canvas3d.style.height = '100%';
                canvas3d.style.backgroundColor = '#161616';
            }
        })();
        """
        
        webView.evaluateJavaScript(positionFixScript, completionHandler: nil)
    }
    
    // 創建協調器來處理WebView事件
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // 協調器類，實現WKNavigationDelegate和WKScriptMessageHandler
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        var parent: ProfileRingView
        
        init(_ parent: ProfileRingView) {
            self.parent = parent
        }
        
        // 處理從JavaScript接收的訊息
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "loadCompleted" {
                DispatchQueue.main.async {
                    if let webView = message.webView {
                        // 使用動畫平滑顯示WebView
                        UIView.animate(withDuration: 0.3) {
                            webView.alpha = 1.0
                        }
                        
                        // 立即應用樣式修復
                        self.applyStyleFixes(to: webView)
                    }
                }
            }
        }
        
        // 頁面加載完成時觸發
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // 確保所有內容都正確載入後再顯示
            applyStyleFixes(to: webView)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 加快顯示速度
                UIView.animate(withDuration: 0.3) {
                    webView.alpha = 1.0
                }
            }
        }
        
        // 頁面開始加載時觸發
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            // 確保WebView一開始是隱藏的，直到內容準備好
            webView.alpha = 0.0
            
            // 在頁面開始加載時也應用樣式
            applyStyleFixes(to: webView)
        }
        
        // 統一的樣式修復方法
        private func applyStyleFixes(to webView: WKWebView) {
            let fixScript = """
            (function() {
                document.documentElement.style.backgroundColor = '#161616';
                document.body.style.backgroundColor = '#161616';
                
                // 創建並確保樣式存在
                var style = document.getElementById('fixed-spline-styles');
                if (!style) {
                    style = document.createElement('style');
                    style.id = 'fixed-spline-styles';
                    style.textContent = `
                        html, body, canvas, .spline-viewer, #canvas3d, iframe {
                            width: 100% !important;
                            height: 100% !important;
                            margin: 0 !important;
                            padding: 0 !important;
                            overflow: hidden !important;
                            background-color: #161616 !important;
                            position: fixed !important;
                            top: 0 !important;
                            left: 0 !important;
                        }
                        canvas {
                            transform: translateY(-20%) !important;
                            object-fit: contain !important;
                        }
                    `;
                    document.head.appendChild(style);
                }
                
                // 直接應用到元素
                var canvas = document.querySelector('canvas');
                if (canvas) {
                    canvas.style.position = 'fixed';
                    canvas.style.top = '0';
                    canvas.style.left = '0';
                    canvas.style.width = '100%';
                    canvas.style.height = '100%';
                    canvas.style.transform = 'translateY(-20%)';
                    canvas.style.backgroundColor = '#161616';
                    canvas.style.objectFit = 'contain';
                }
                
                var splineViewer = document.querySelector('.spline-viewer');
                if (splineViewer) {
                    splineViewer.style.position = 'fixed';
                    splineViewer.style.top = '0';
                    splineViewer.style.left = '0';
                    splineViewer.style.width = '100%';
                    splineViewer.style.height = '100%';
                    splineViewer.style.backgroundColor = '#161616';
                }
                
                var canvas3d = document.getElementById('canvas3d');
                if (canvas3d) {
                    canvas3d.style.position = 'fixed';
                    canvas3d.style.top = '0';
                    canvas3d.style.left = '0';
                    canvas3d.style.width = '100%';
                    canvas3d.style.height = '100%';
                    canvas3d.style.backgroundColor = '#161616';
                }
                
                // 優化：清理不必要元素，提高性能
                var unusedElements = document.querySelectorAll('.spline-ui, .spline-controls');
                if (unusedElements.length > 0) {
                    for (var i = 0; i < unusedElements.length; i++) {
                        unusedElements[i].remove();
                    }
                }
            })();
            """
            
            webView.evaluateJavaScript(fixScript, completionHandler: nil)
        }
        
        // 處理新窗口打開請求
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // 阻止新窗口打開，在當前窗口加載
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
    }
    
    // 計算最佳WebView尺寸，保持正確長寬比
    private func calculateOptimalSize(for screenSize: CGSize) -> CGSize {
        var width: CGFloat
        var height: CGFloat
        
        // 縮小系數 - 降低20%
        let scaleFactor: CGFloat = 0.96 // 1.2 * 0.8 = 0.96
        
        // 確保容器總是更寬而非更高
        if screenSize.width / screenSize.height > splineAspectRatio {
            // 以高度為基準計算寬度
            height = screenSize.height * scaleFactor 
            width = height * splineAspectRatio
        } else {
            // 以寬度為基準計算高度
            width = screenSize.width * scaleFactor
            height = width / splineAspectRatio
        }
        
        // 返回計算出的最佳尺寸
        return CGSize(width: width, height: height)
    }
}

// 自定義進度條樣式
struct RingProgressStyle: ProgressViewStyle {
    var ringIndex: Int
    
    func makeBody(configuration: Configuration) -> some View {
        let gradient = getGradient()
        
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                // 背景軌道
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                // 前景進度
                RoundedRectangle(cornerRadius: 10)
                    .fill(gradient)
                    .frame(width: geo.size.width * CGFloat(configuration.fractionCompleted ?? 0), height: 8)
            }
        }
    }
    
    private func getGradient() -> LinearGradient {
        switch ringIndex {
        case 0: // 翠流之戒 - 綠色漸層
            return LinearGradient(
                colors: [Color(hexString: "00C9A7"), Color(hexString: "128760")],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 1: // 薰育之戒 - 紫色漸層
            return LinearGradient(
                colors: [Color(hexString: "845EC2"), Color(hexString: "4B4453")],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 2: // 橙心之戒 - 橙色漸層
            return LinearGradient(
                colors: [Color(hexString: "FF9671"), Color(hexString: "C34A36")],
                startPoint: .leading,
                endPoint: .trailing
            )
        case 3: // 赤光之戒 - 紅色漸層
            return LinearGradient(
                colors: [Color(hexString: "FF5E78"), Color(hexString: "B91E46")],
                startPoint: .leading,
                endPoint: .trailing
            )
        default:
            return LinearGradient(
                colors: [accentColor1, accentColor2],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}

struct ProfileTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : Color.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ?
                    RoundedRectangle(cornerRadius: 25)
                        .fill(actionGradient)
                        .shadow(color: accentColor1.opacity(0.2), radius: 4, x: 0, y: 2)
                         : nil
                )
        }
    }
}

struct MyGroupsTab: View {
    let groups = [
        (title: "星巴克買一送一", type: "咖啡優惠", status: "進行中"),
        (title: "台北到桃園共乘", type: "共乘", status: "已結束"),
        (title: "麥當勞早餐優惠", type: "美食優惠", status: "進行中")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(groups, id: \.title) { group in
                ActivityRow(title: group.title, type: group.type, status: group.status)
            }
            
            if groups.isEmpty {
                Text("還沒有參加過任何揪團")
                    .foregroundColor(Color.secondary)
                    .padding(.top, 40)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct FavoritesTab: View {
    let favorites = [
        (title: "喜茶買一送一", type: "咖啡優惠", location: "信義區"),
        (title: "健身房夥伴", type: "運動", location: "大安區")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(favorites, id: \.title) { favorite in
                FavoriteRow(
                    title: favorite.title,
                    type: favorite.type,
                    location: favorite.location
                )
            }
            
            if favorites.isEmpty {
                Text("還沒有收藏任何揪團")
                    .foregroundColor(Color.secondary)
                    .padding(.top, 40)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

struct ActivityRow: View {
    let title: String
    let type: String
    let status: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 50, height: 50)
                
                Image(systemName: getIconName(for: type))
                    .font(.system(size: 20))
                    .foregroundColor(accentColor1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.primary)
                
                HStack {
                    Text(type)
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                    
                    StatusTag(status: status)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.secondary)
                .font(.system(size: 14))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 4, x:0, y:1)
        )
    }
    
    private func getIconName(for type: String) -> String {
        switch type {
        case "咖啡優惠": return "cup.and.saucer.fill"
        case "美食優惠": return "fork.knife"
        case "共乘": return "car.fill"
        case "購物優惠": return "bag.fill"
        case "運動": return "figure.run"
        default: return "ellipsis.circle.fill"
        }
    }
}

struct FavoriteRow: View {
    let title: String
    let type: String
    let location: String
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 50, height: 50)
                
                Image(systemName: getIconName(for: type))
                    .font(.system(size: 20))
                    .foregroundColor(accentColor1)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.primary)
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(accentColor1)
                        .font(.system(size: 12))
                    
                    Text(location)
                        .font(.system(size: 12))
                        .foregroundColor(Color.secondary)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Button(action: {
                // 移除收藏
            }) {
                Image(systemName: "heart.fill")
                    .foregroundColor(accentColor1)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 4, x:0, y:1)
        )
    }
    
    private func getIconName(for type: String) -> String {
        switch type {
        case "咖啡優惠": return "cup.and.saucer.fill"
        case "美食優惠": return "fork.knife"
        case "共乘": return "car.fill"
        case "購物優惠": return "bag.fill"
        case "運動": return "figure.run"
        default: return "ellipsis.circle.fill"
        }
    }
}

struct StatusTag: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(status == "進行中" ? .white : Color.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(status == "進行中" ? accentColor1 : Color.gray.opacity(0.3))
            )
    }
}

struct SettingsView: View {
    @EnvironmentObject private var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @State private var notifications = true
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("個人設定").foregroundColor(accentColor1)) {
                    NavigationLink(destination: Text("編輯個人資料")) {
                        SettingRow(icon: "person.fill", title: "編輯個人資料")
                    }
                    
                    NavigationLink(destination: Text("我的位置")) {
                        SettingRow(icon: "location.fill", title: "我的位置")
                    }
                    
                    NavigationLink(destination: RingSelectionView()) {
                        SettingRow(icon: "circles.hexagongrid.fill", title: "變更我的戒指")
                    }
                }
                
                Section(header: Text("偏好設定").foregroundColor(accentColor1)) {
                    Toggle(isOn: $notifications) {
                        SettingRow(icon: "bell.fill", title: "推播通知")
                    }
                    .tint(accentColor1)
                    
                    NavigationLink(destination: Text("語言設定")) {
                        SettingRow(icon: "globe", title: "語言設定")
                    }
                }
                
                Section(header: Text("其他").foregroundColor(accentColor1)) {
                    NavigationLink(destination: Text("幫助中心")) {
                        SettingRow(icon: "questionmark.circle.fill", title: "幫助中心")
                    }
                    
                    NavigationLink(destination: Text("關於我們")) {
                        SettingRow(icon: "info.circle.fill", title: "關於我們")
                    }
                    
                    Button(action: {
                        authManager.signOut()
                        dismiss()
                    }) {
                        SettingRow(icon: "arrow.right.square.fill", title: "登出")
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(Color(.systemGroupedBackground))
            .scrollContentBackground(.hidden)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(accentColor1)
                }
            }
        }
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(accentColor1)
                .frame(width: 28)
            
            Text(title)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager.shared)
} 