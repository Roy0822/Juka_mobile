import SwiftUI

struct ThemeToggle: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Menu {
            ForEach(AppTheme.allCases) { theme in
                Button(action: {
                    themeManager.selectedTheme = theme
                }) {
                    HStack {
                        Text(theme.displayName)
                        Spacer()
                        if themeManager.selectedTheme == theme {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: themeManager.selectedTheme.icon)
                    .font(.system(size: 16))
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.05))
            )
        }
    }
}

struct ThemeModeIcon: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Image(systemName: colorScheme == .dark ? "moon.fill" : "sun.max.fill")
            .font(.system(size: 16))
            .foregroundColor(colorScheme == .dark ? .white : .orange)
    }
}

#Preview {
    VStack {
        ThemeToggle()
        ThemeModeIcon()
    }
    .padding()
    .environmentObject(ThemeManager.shared)
} 