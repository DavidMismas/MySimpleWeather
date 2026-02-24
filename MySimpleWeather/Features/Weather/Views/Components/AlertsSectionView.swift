import SwiftUI

struct AlertsSectionView: View {
    let alerts: [WeatherAlert]
    let timezoneOffset: Int

    var body: some View {
        if !alerts.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Weather Alerts")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)

                VStack(spacing: 10) {
                    ForEach(alerts) { alert in
                        DisclosureGroup {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(alert.description)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundStyle(AppTheme.secondaryText)

                                if let tags = alert.tags, !tags.isEmpty {
                                    Text(tags.joined(separator: ", "))
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(AppTheme.secondaryText)
                                }
                            }
                            .padding(.top, 6)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(alert.event)
                                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                                    .foregroundStyle(AppTheme.primaryText)

                                Text(
                                    "\(WeatherFormatters.timeString(unix: alert.start, timezoneOffset: timezoneOffset, format: "MMM d, HH:mm"))"
                                    + " - "
                                    + "\(WeatherFormatters.timeString(unix: alert.end, timezoneOffset: timezoneOffset, format: "MMM d, HH:mm"))"
                                )
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(AppTheme.secondaryText)
                            }
                        }
                        .tint(.white)
                        .padding(12)
                        .background(Color.red.opacity(0.22), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
            .glassCard()
        }
    }
}
