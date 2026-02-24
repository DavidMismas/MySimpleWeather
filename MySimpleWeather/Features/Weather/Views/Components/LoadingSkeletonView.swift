import SwiftUI

struct LoadingSkeletonView: View {
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.22))
                .frame(height: 130)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.20))
                .frame(height: 340)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.20))
                .frame(height: 190)

            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.20))
                .frame(height: 290)
        }
        .redacted(reason: .placeholder)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "cloud.sun.bolt")
                .font(.system(size: 46))
                .foregroundStyle(AppTheme.primaryText)
            Text(title)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.primaryText)
            Text(message)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
            Button(buttonTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.25))
                .foregroundStyle(.white)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .glassCard()
    }
}
