import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            hapticFeedback.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(AppStyles.primaryGradient)
                    .frame(width: 70, height: 70)
                    .shadow(
                        color: Color.pink.opacity(0.5),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
                
                Text("揪")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation {
                        isPressed = false
                    }
                }
        )
    }
}

// Mini version of FAB for secondary actions
struct MiniFAB: View {
    let systemImage: String
    let action: () -> Void
    let hapticFeedback = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        Button(action: {
            hapticFeedback.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                    .shadow(
                        color: AppStyles.shadowColor,
                        radius: AppStyles.shadowRadius / 2,
                        x: AppStyles.shadowX,
                        y: AppStyles.shadowY / 2
                    )
                
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppStyles.primary)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color(.systemBackground).ignoresSafeArea()
        
        VStack(spacing: 40) {
            FloatingActionButton {
                print("FAB tapped!")
            }
            
            HStack(spacing: 20) {
                MiniFAB(systemImage: "location.fill") {
                    print("Location tapped!")
                }
                
                MiniFAB(systemImage: "camera.fill") {
                    print("Camera tapped!")
                }
            }
        }
    }
} 