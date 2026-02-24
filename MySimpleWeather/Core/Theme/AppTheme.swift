import SwiftUI

enum AppTheme {
    static let top = Color(red: 0.24, green: 0.17, blue: 0.46)
    static let middle = Color(red: 0.52, green: 0.22, blue: 0.47)
    static let bottom = Color(red: 0.67, green: 0.33, blue: 0.52)

    static let backgroundGradient = LinearGradient(
        colors: [top, middle, bottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cardBackground = Color.white.opacity(0.18)
    static let cardBorder = Color.white.opacity(0.28)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.78)
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(AppTheme.cardBorder, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}
