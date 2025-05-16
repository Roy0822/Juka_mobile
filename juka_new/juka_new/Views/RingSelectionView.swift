import SwiftUI
import WebKit

/**
 顯示使用者可選擇的戒指選項
 */
struct RingSelectionView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var currentRingIndex = 0
    @State private var isSplineLoaded = false
    @State private var ringURLs: [String] = [
        "https://my.spline.design/ring2-4GUFZ0z6yPVxyB1cV3H3XMSU/",
        "https://my.spline.design/ringswithinteractivedisplacementtexturecopy-LohNRUF5rW1ErwMTdQCkVW6X/",
        "https://my.spline.design/ring1copycopy-gKSZvT46xNPgIVCfazizXShK/",
        "https://my.spline.design/ring1copycopy-CmuebjTIDPbOjhYsFsYo8SgY/"
    ]
    @State private var ringNames: [String] = ["翠流之戒", "薰育之戒", "橙心之戒", "赤光之戒"]
    
    // 添加過渡動畫的狀態
    @State private var isTransitioning = false
    @State private var transitionOpacity: Double = 0
    @State private var buttonGlowing = false
    
    // 定義背景色
    let backgroundColor = Color(hexString: "161616")
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                // 使用固定長寬比的容器來放置WebView
                AspectRatioWebViewContainer(
                    currentRingIndex: $currentRingIndex,
                    isSplineLoaded: $isSplineLoaded,
                    ringURL: ringURLs[currentRingIndex],
                    screenSize: geometry.size
                )
                .id(currentRingIndex) // 添加id強制在切換時重建視圖
                .ignoresSafeArea()
                
                // 過渡動畫層 - 使用額外的動畫效果
                if isTransitioning {
                    backgroundColor
                        .ignoresSafeArea()
                        .opacity(transitionOpacity)
                        .animation(.easeInOut(duration: 0.35), value: transitionOpacity)
                }
                
                VStack {
                    // 頂部標題
                    Text("選擇你的戒指")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.top, 60)
                    
                    Spacer()
                    
                    // 底部UI元素
                    VStack(spacing: 20) {
                        // 將1/4和戒指名稱移至此處（按鈕上方）
                        VStack(spacing: 10) {
                            Text("\(currentRingIndex + 1) / \(ringURLs.count)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text(ringNames[currentRingIndex])
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.bottom, 5)
                        }
                        .padding(.bottom, 10)
                        
                        Button(action: {
                            // 點擊選擇當前戒指
                            authManager.selectRing(index: currentRingIndex)
                        }) {
                            Text("選擇此戒指")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(height: 56)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 28)
                                        .stroke(Color.white, lineWidth: 2)
                                        .shadow(color: buttonGlowing ? Color.white.opacity(0.8) : Color.white.opacity(0.3), 
                                               radius: buttonGlowing ? 10 : 4)
                                        .scaleEffect(buttonGlowing ? 1.04 : 1.0)
                                )
                                .padding(.horizontal, 20)
                        }
                        .padding(.horizontal, 20)
                        .shadow(color: buttonGlowing ? Color.white.opacity(0.5) : Color.white.opacity(0.2), 
                               radius: buttonGlowing ? 15 : 5)
                        .onAppear {
                            // 開始按鈕脈動動畫
                            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                buttonGlowing = true
                            }
                        }
                        
                        Button(action: {
                            // 跳過選擇
                            authManager.skipRingSelection()
                        }) {
                            Text("跳過")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.bottom, 20)
                        }
                    }
                    .padding(.bottom, 50)
                }
                
                // 左右導航按鈕 - 已移除圓形背景，只保留箭頭
                HStack {
                    // 左側按鈕
                    if currentRingIndex > 0 {
                        Button(action: {
                            switchToRing(currentRingIndex - 1)
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.leading, 20)
                    } else {
                        Spacer()
                            .frame(width: 60)
                    }
                    
                    Spacer()
                    
                    // 右側按鈕
                    if currentRingIndex < ringURLs.count - 1 {
                        Button(action: {
                            switchToRing(currentRingIndex + 1)
                        }) {
                            Image(systemName: "arrow.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.trailing, 20)
                    } else {
                        Spacer()
                            .frame(width: 60)
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        // 左右滑動切換戒指
                        let threshold: CGFloat = 50
                        if value.translation.width > threshold && currentRingIndex > 0 {
                            // 向右滑動，切換到上一個
                            switchToRing(currentRingIndex - 1)
                        } else if value.translation.width < -threshold && currentRingIndex < ringURLs.count - 1 {
                            // 向左滑動，切換到下一個
                            switchToRing(currentRingIndex + 1)
                        }
                    }
            )
        }
    }
    
    // 優化的過渡方法，使用更平滑的動畫效果
    private func switchToRing(_ index: Int) {
        // 避免多次觸發
        guard !isTransitioning else { return }
        
        // 開始過渡
        isTransitioning = true
        
        // 第一階段：淡入黑色覆蓋層 (0.35秒)
        // 使用滑動插值，開始較慢，中間加速，結束較慢
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            transitionOpacity = 0.95
        }
        
        // 第二階段：切換戒指 (在0.25秒後執行)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            // 切換到新戒指 (不使用動畫，因為背後被遮蓋)
            currentRingIndex = index
            isSplineLoaded = false
            
            // 第三階段：讓新戒指有時間加載 (0.3秒)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // 第四階段：淡出黑色覆蓋層 (0.4秒)
                // 使用彈簧動畫，更有活力和自然感
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    transitionOpacity = 0
                }
                
                // 第五階段：結束過渡
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isTransitioning = false
                }
            }
        }
    }
}

// 固定長寬比的WebView容器
struct AspectRatioWebViewContainer: UIViewRepresentable {
    @Binding var currentRingIndex: Int
    @Binding var isSplineLoaded: Bool
    var ringURL: String
    var screenSize: CGSize
    
    // Spline項目原始長寬比
    private let splineAspectRatio: CGFloat = 758.0 / 1372.0
    
    func makeUIView(context: Context) -> UIView {
        // 創建一個容器視圖來控制WebView的大小
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1.0) // #161616
        
        // 創建WebView
        let webView = createWebView(context: context)
        
        // 將WebView添加到容器
        containerView.addSubview(webView)
        
        // 設置WebView的約束，確保正確比例
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // 計算基於螢幕大小的最佳尺寸
        let webViewSize = calculateOptimalSize(for: screenSize)
        
        // 水平居中
        NSLayoutConstraint.activate([
            webView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            webView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            webView.widthAnchor.constraint(equalToConstant: webViewSize.width),
            webView.heightAnchor.constraint(equalToConstant: webViewSize.height)
        ])
        
        // 保存WebView的參考
        context.coordinator.webView = webView
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 取得WebView
        guard let webView = context.coordinator.webView else { return }
        
        // 更新WebView的大小
        let webViewSize = calculateOptimalSize(for: screenSize)
        
        for constraint in webView.constraints {
            if constraint.firstAttribute == .width {
                constraint.constant = webViewSize.width
            } else if constraint.firstAttribute == .height {
                constraint.constant = webViewSize.height
            }
        }
        
        // 檢查URL是否需要更新
        let currentURL = webView.url?.absoluteString ?? ""
        
        // 如果URL不匹配當前的ringURL，重新加載
        if !currentURL.contains(ringURL) {
            if let url = URL(string: ringURL) {
                let request = URLRequest(url: url)
                webView.load(request)
                // 重置Spline準備狀態
                context.coordinator.isSplineReady = false
            }
        }
        
        // 儲存當前索引
        if context.coordinator.currentRingIndex != currentRingIndex || context.coordinator.isTransitioning != isSplineLoaded {
            context.coordinator.currentRingIndex = currentRingIndex
            context.coordinator.isTransitioning = isSplineLoaded
            
            // 如果索引發生變化且Spline已加載，則移動到新的戒指位置
            if context.coordinator.isSplineReady && !isSplineLoaded {
                context.coordinator.moveToRing(webView, index: currentRingIndex)
            }
        }
    }
    
    // 計算WebView的最佳尺寸，保持Spline項目的原始長寬比
    private func calculateOptimalSize(for screenSize: CGSize) -> CGSize {
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width
        
        // 如果基於高度計算的寬度小於螢幕寬度，則使用高度優先
        let heightBasedWidth = screenHeight * splineAspectRatio
        if heightBasedWidth <= screenWidth {
            return CGSize(width: heightBasedWidth, height: screenHeight)
        }
        
        // 否則使用寬度優先
        let widthBasedHeight = screenWidth / splineAspectRatio
        return CGSize(width: screenWidth, height: widthBasedHeight)
    }
    
    // 創建配置好的WebView
    private func createWebView(context: Context) -> WKWebView {
        // 創建WKWebView配置
        let config = WKWebViewConfiguration()
        let userController = WKUserContentController()
        
        // 設置初始視口比例和內容縮放
        let viewportScript = WKUserScript(
            source: """
            // 設置正確的視口尺寸
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
            
            // 添加CSS確保Spline全螢幕顯示
            var style = document.createElement('style');
            style.textContent = `
                html, body { 
                    width: 100% !important; 
                    height: 100% !important; 
                    margin: 0 !important; 
                    padding: 0 !important; 
                    overflow: hidden !important;
                    background-color: #161616 !important;
                }
                
                canvas { 
                    width: 100% !important; 
                    height: 100% !important; 
                    margin: 0 !important; 
                    padding: 0 !important;
                    object-fit: contain !important;
                }
                
                #canvas3d {
                    width: 100% !important;
                    height: 100% !important;
                    object-fit: contain !important;
                }
                
                .spline-viewer {
                    width: 100% !important;
                    height: 100% !important;
                    background-color: #161616 !important;
                }
                
                iframe {
                    width: 100% !important;
                    height: 100% !important;
                    border: none !important;
                    object-fit: contain !important;
                }
                
                /* 確保所有容器和畫布都使用包含模式而非拉伸 */
                * {
                    object-fit: contain !important;
                    background-color: #161616 !important;
                }
            `;
            style.id = 'spline-custom-styles';
            document.getElementsByTagName('head')[0].appendChild(style);
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        userController.addUserScript(viewportScript)
        
        // 注入腳本以操作Spline場景
        let script = WKUserScript(
            source: """
            // 全域變數和初始化
            window.addEventListener('load', function() {
                console.log('頁面加載完成，初始化Spline控制...');
                window.splineLoaded = false;
                window.splineError = false;
                window.lastRingIndex = 0;
                
                // 確保整個文檔背景為指定色
                document.body.style.backgroundColor = '#161616';
                document.documentElement.style.backgroundColor = '#161616';
                
                // 監聽Spline加載完成事件
                window.splineReadyCheck = setInterval(function() {
                    // 檢查Spline是否存在並準備好
                    if (window.spline && window.spline.load) {
                        clearInterval(window.splineReadyCheck);
                        window.splineLoaded = true;
                        console.log('Spline已加載完成，準備控制視圖');
                        
                        // 通知Swift Spline已加載
                        window.webkit.messageHandlers.splineReady.postMessage("Spline已準備好");
                    }
                }, 200);
                
                // 超時處理
                setTimeout(function() {
                    if (!window.splineLoaded) {
                        clearInterval(window.splineReadyCheck);
                        window.splineError = true;
                        console.error('Spline加載超時');
                        window.webkit.messageHandlers.splineError.postMessage("加載超時");
                    }
                }, 10000);
            });
            
            // 模擬水平滑動的方法
            function simulateHorizontalSwipe(startX, endX, duration) {
                if (!window.splineLoaded) return "Spline尚未加載";
                
                console.log(`模擬滑動：從 ${startX} 到 ${endX}`);
                
                // 創建觸摸開始事件
                const touchStartEvent = new TouchEvent('touchstart', {
                    bubbles: true,
                    cancelable: true,
                    view: window,
                    touches: [
                        new Touch({
                            identifier: Date.now(),
                            target: document.body,
                            clientX: startX,
                            clientY: window.innerHeight / 2,
                            pageX: startX,
                            pageY: window.innerHeight / 2
                        })
                    ]
                });
                
                // 創建觸摸結束事件
                const touchEndEvent = new TouchEvent('touchend', {
                    bubbles: true,
                    cancelable: true,
                    view: window,
                    touches: []
                });
                
                // 分發事件
                document.body.dispatchEvent(touchStartEvent);
                
                // 使用requestAnimationFrame實現平滑動畫
                const startTime = Date.now();
                const endTime = startTime + duration;
                
                function animate() {
                    const now = Date.now();
                    if (now >= endTime) {
                        document.body.dispatchEvent(touchEndEvent);
                        return;
                    }
                    
                    const progress = (now - startTime) / duration;
                    const currentX = startX + (endX - startX) * progress;
                    
                    // 創建觸摸移動事件
                    const touchMoveEvent = new TouchEvent('touchmove', {
                        bubbles: true,
                        cancelable: true,
                        view: window,
                        touches: [
                            new Touch({
                                identifier: Date.now(),
                                target: document.body,
                                clientX: currentX,
                                clientY: window.innerHeight / 2,
                                pageX: currentX,
                                pageY: window.innerHeight / 2
                            })
                        ]
                    });
                    
                    document.body.dispatchEvent(touchMoveEvent);
                    requestAnimationFrame(animate);
                }
                
                requestAnimationFrame(animate);
                return "開始模擬滑動";
            }
            
            // 嘗試使用Spline API移動場景的方法
            function moveToRing(ringIndex) {
                if (!window.splineLoaded) return "Spline尚未加載";
                
                try {
                    console.log(`嘗試移動到戒指 ${ringIndex}`);
                    
                    // 方式1: 使用內置的state系統，如果存在
                    if (window.spline.setState) {
                        window.spline.setState({ currentRing: ringIndex });
                        return "使用setState成功";
                    }
                    
                    // 方式2: 嘗試使用特定的方法切換視角
                    if (window.spline.switchView) {
                        window.spline.switchView(ringIndex);
                        return "使用switchView成功";
                    }
                    
                    // 方式3: 嘗試直接控制相機
                    if (window.spline.cameraTarget) {
                        // 根據不同的戒指索引設置不同的目標點
                        const targets = [
                            { x: -0.8, y: 0, z: 0 },
                            { x: -0.2, y: 0, z: 0 },
                            { x: 0.4, y: 0, z: 0 },
                            { x: 1.0, y: 0, z: 0 }
                        ];
                        window.spline.cameraTarget = targets[ringIndex];
                        return "設置相機目標成功";
                    }
                    
                    // 方式4: 嘗試使用場景內置的事件系統
                    if (window.spline.emitEvent) {
                        window.spline.emitEvent('ring:select', ringIndex);
                        return "觸發選擇事件成功";
                    }
                    
                    // 方式5: 模擬滑動手勢 (fallback)
                    const screenWidth = window.innerWidth;
                    const direction = ringIndex > window.lastRingIndex ? -1 : 1; // 左右方向
                    const startX = screenWidth / 2;
                    const endX = startX + (direction * screenWidth * 0.4); // 滑動40%屏幕寬度
                    window.lastRingIndex = ringIndex;
                    
                    return simulateHorizontalSwipe(startX, endX, 500);
                } catch (e) {
                    console.error("移動場景錯誤:", e);
                    return "錯誤: " + e.toString();
                }
            }
            
            // 禁用原生觸摸滑動效果，讓我們可以完全控制
            document.addEventListener('touchmove', function(e) {
                if (e.target.tagName !== 'CANVAS') return;
                e.preventDefault();
            }, { passive: false });
            """,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        
        userController.addUserScript(script)
        userController.add(context.coordinator, name: "splineReady")
        userController.add(context.coordinator, name: "splineError")
        config.userContentController = userController
        
        // 創建WKWebView
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1.0) // #161616
        webView.scrollView.backgroundColor = UIColor(red: 22/255, green: 22/255, blue: 22/255, alpha: 1.0) // #161616
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = context.coordinator
        
        // 允許用戶交互，讓Spline接收事件，但不允許滾動
        webView.isUserInteractionEnabled = true
        
        // 設置webView的內容模式，確保內容正確縮放而不變形
        webView.contentMode = .scaleAspectFit
        
        // 加載Spline URL - 使用提供的新URL
        if let url = URL(string: ringURL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: AspectRatioWebViewContainer
        var webView: WKWebView?
        var isSplineReady = false
        var currentRingIndex = 0
        var isTransitioning = false
        
        init(_ parent: AspectRatioWebViewContainer) {
            self.parent = parent
        }
        
        // 處理來自JavaScript的消息
        public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "splineReady" {
                print("Spline場景已加載完成！消息：\(message.body)")
                isSplineReady = true
            } else if message.name == "splineError" {
                print("Spline加載錯誤: \(message.body)")
            }
        }
        
        // 頁面加載完成
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("網頁加載完成，等待Spline初始化...")
            
            // 檢查Spline物件
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.checkSplineObject(webView)
            }
        }
        
        // 檢查Spline物件結構
        private func checkSplineObject(_ webView: WKWebView) {
            let debugScript = """
            (function() {
                if (!window.spline) return "Spline尚未加載";
                
                var result = {};
                // 枚舉spline物件的所有屬性和方法
                for (var prop in window.spline) {
                    var type = typeof window.spline[prop];
                    result[prop] = type;
                }
                
                // 檢查spline對象中可能有用的方法
                var usefulMethods = ["load", "setState", "setCamera", "switchView", "emitEvent"];
                for (var i = 0; i < usefulMethods.length; i++) {
                    if (typeof window.spline[usefulMethods[i]] === "function") {
                        result["found_" + usefulMethods[i]] = true;
                    }
                }
                
                return JSON.stringify(result);
            })();
            """
            
            webView.evaluateJavaScript(debugScript) { result, error in
                if let error = error {
                    print("查詢Spline物件錯誤: \(error)")
                } else if let result = result as? String {
                    print("Spline物件結構: \(result)")
                }
            }
        }
        
        // 移動到指定的戒指
        public func moveToRing(_ webView: WKWebView, index: Int) {
            let moveScript = "moveToRing(\(index));"
            
            webView.evaluateJavaScript(moveScript) { result, error in
                if let error = error {
                    print("移動到戒指錯誤: \(error)")
                } else if let result = result as? String {
                    print("移動到戒指 \(index) 結果: \(result)")
                }
            }
        }
    }
}

#Preview {
    RingSelectionView()
        .environmentObject(AuthenticationManager.shared)
} 
 