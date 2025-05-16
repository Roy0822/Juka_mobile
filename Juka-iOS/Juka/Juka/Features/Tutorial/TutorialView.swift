import SwiftUI

// 教學步驟結構
struct TutorialStep {
    let id: Int
    let title: String
    let description: String
    let iconName: String
}

// 用戶資料存儲管理器
class UserPreferencesManager: ObservableObject {
    @Published var completedTutorial: Bool {
        didSet {
            UserDefaults.standard.set(completedTutorial, forKey: "completedTutorial")
        }
    }
    
    init() {
        self.completedTutorial = UserDefaults.standard.bool(forKey: "completedTutorial")
    }
    
    func resetTutorial() {
        completedTutorial = false
    }
    
    func markTutorialCompleted() {
        completedTutorial = true
    }
}

struct TutorialView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var preferencesManager = UserPreferencesManager()
    @State private var currentPage = 0
    
    // 定義教學步驟
    let tutorialSteps: [TutorialStep] = [
        TutorialStep(
            id: 0,
            title: "探索附近揪團",
            description: "在地圖上查看周圍的揪團機會，找到與您興趣相符的活動。靠近指示點可以看到更多詳細資訊。",
            iconName: "map.fill"
        ),
        TutorialStep(
            id: 1,
            title: "加入或建立揪團",
            description: "找到感興趣的活動後，點擊加入！或者，您也可以自己建立一個新揪團，邀請周圍的人參與。",
            iconName: "person.3.fill"
        ),
        TutorialStep(
            id: 2,
            title: "即時聊天",
            description: "與揪團成員即時溝通，討論活動細節，確保大家都在相同頁面上。",
            iconName: "bubble.left.and.bubble.right.fill"
        ),
        TutorialStep(
            id: 3,
            title: "分享並邀請朋友",
            description: "通過分享功能，您可以邀請朋友加入您的揪團，或者同時加入其他有趣的活動。",
            iconName: "square.and.arrow.up.fill"
        ),
        TutorialStep(
            id: 4,
            title: "即刻開始體驗！",
            description: "恭喜您完成教學！現在就開始探索附近的揪團，認識新朋友，一起度過美好時光吧！",
            iconName: "hand.thumbsup.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // 背景漸層 - 調整透明度為0.3
            LinearGradient(
                colors: [Color(hex: "5170FF").opacity(0.3), Color(hex: "FF66C4").opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // 疊加的圓形裝飾
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: geo.size.width * 0.8)
                    .position(x: geo.size.width * 0.9, y: geo.size.height * 0.15)
                
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: geo.size.width * 0.6)
                    .position(x: geo.size.width * 0.1, y: geo.size.height * 0.85)
            }
            
            // 內容
            VStack {
                // 跳過按鈕
                HStack {
                    Spacer()
                    
                    if currentPage < tutorialSteps.count - 1 {
                        Button("跳過") {
                            preferencesManager.markTutorialCompleted()
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.3))
                        )
                        .padding()
                    }
                }
                
                Spacer()
                
                // 圖片佔位符（未來會替換為實際圖片）
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 240, height: 240)
                    
                    Image(systemName: tutorialSteps[currentPage].iconName)
                        .font(.system(size: 100))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                // 步驟內容 - 固定高度防止跳動
                VStack(spacing: 20) {
                    // 標題
                    Text(tutorialSteps[currentPage].title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    // 描述 - 固定高度
                    Text(tutorialSteps[currentPage].description)
                        .font(.system(size: 16))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 32)
                        .frame(height: 80) // 固定高度
                }
                .frame(height: 160) // 為整個說明區域設置固定高度
                .padding(.bottom, 20)
                
                Spacer()
                
                // 分頁指示器
                HStack(spacing: 12) {
                    ForEach(0..<tutorialSteps.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.bottom, 30)
                
                // 按鈕
                Button(action: {
                    withAnimation {
                        if currentPage < tutorialSteps.count - 1 {
                            currentPage += 1
                        } else {
                            preferencesManager.markTutorialCompleted()
                            dismiss()
                        }
                    }
                }) {
                    Text(currentPage < tutorialSteps.count - 1 ? "繼續" : "開始使用")
                        .font(.headline)
                        .foregroundColor(currentPage < tutorialSteps.count - 1 ? .white : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Group {
                                if currentPage < tutorialSteps.count - 1 {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "5170FF").opacity(0.8), Color(hex: "FF66C4").opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "5170FF"), Color(hex: "FF66C4")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.white, lineWidth: 1)
                                        )
                                }
                            }
                        )
                        .padding(.horizontal, 32)
                        .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.bottom, 50)
            }
            .padding()
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // 左右滑動切換頁面
                    if value.translation.width < -50 && currentPage < tutorialSteps.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else if value.translation.width > 50 && currentPage > 0 {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                }
        )
    }
}

#Preview {
    TutorialView()
} 