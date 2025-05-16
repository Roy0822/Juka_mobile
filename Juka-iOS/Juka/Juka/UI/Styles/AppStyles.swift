import SwiftUI

struct AppStyles {
    // MARK: - Colors
    static let primary = Color(hex: "a86be2")
    static let secondary = Color.purple
    static let accent = Color.orange
    
    // Dynamic colors that adapt to dark/light mode
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    static let label = Color(.label)
    static let secondaryLabel = Color(.secondaryLabel)
    static let separator = Color(.separator)
    static let fill = Color(.systemFill)
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "5170FF"), Color(hex: "FF66C4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Dynamic gradient for dark/light mode
    static func adaptiveGradient(for colorScheme: ColorScheme) -> LinearGradient {
        switch colorScheme {
        case .dark:
            return LinearGradient(
                colors: [Color(hex: "5170FF").opacity(0.8), Color(hex: "FF66C4").opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return primaryGradient
        }
    }
    
    // MARK: - Corner Radius
    static let cornerRadius: CGFloat = 20
    static let largeCornerRadius: CGFloat = 25
    
    // MARK: - Shadow
    static var shadowColor: Color {
        Color.black.opacity(0.1)
    }
    static let shadowRadius: CGFloat = 10
    static let shadowX: CGFloat = 0
    static let shadowY: CGFloat = 5
    
    // MARK: - Padding
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
    
    // MARK: - Animation
    static let animation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    // MARK: - Typography
    enum Typography {
        static let title = Font.title.weight(.bold)
        static let subtitle = Font.title2.weight(.semibold)
        static let body = Font.body
        static let caption = Font.caption
        static let button = Font.headline.weight(.semibold)
    }
}

// MARK: - View Modifiers
struct GlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(AppStyles.padding)
            .background(
                colorScheme == .dark ? 
                    Color(.systemGray6).opacity(0.7) : 
                    Color.white.opacity(0.7)
            )
            .cornerRadius(AppStyles.cornerRadius)
            .shadow(
                color: AppStyles.shadowColor,
                radius: AppStyles.shadowRadius,
                x: AppStyles.shadowX,
                y: AppStyles.shadowY
            )
    }
}

struct FloatingNavBarModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(AppStyles.padding)
            .background(
                colorScheme == .dark ?
                    Color(.systemGray5).opacity(0.7) :
                    Color.white.opacity(0.7)
            )
            .cornerRadius(AppStyles.cornerRadius)
            .shadow(
                color: AppStyles.shadowColor,
                radius: AppStyles.shadowRadius / 2,
                x: AppStyles.shadowX,
                y: AppStyles.shadowY / 2
            )
            .padding(.horizontal, AppStyles.padding)
            .padding(.top, AppStyles.smallPadding)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppStyles.Typography.button)
            .foregroundColor(.white)
            .padding(.vertical, AppStyles.smallPadding)
            .padding(.horizontal, AppStyles.padding)
            .background(
                AppStyles.primaryGradient
                    .opacity(configuration.isPressed ? 0.8 : 1)
            )
            .cornerRadius(AppStyles.cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Extension for View
extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
    
    func floatingNavBar() -> some View {
        self.modifier(FloatingNavBarModifier())
    }
} 