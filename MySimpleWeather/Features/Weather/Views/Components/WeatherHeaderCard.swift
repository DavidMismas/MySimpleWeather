import SwiftUI

struct WeatherHeaderCard: View {
    let locationName: String
    let timezone: String?
    let coordinates: (lat: Double, lon: Double)?
    let lastUpdated: Date?
    let units: WeatherUnits

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                Text(locationName)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primaryText)
                    .minimumScaleFactor(0.7)

                Spacer(minLength: 8)

                Image(systemName: "house.and.flag.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText.opacity(0.9))
                    .padding(.top, 8)
            }

            HStack(spacing: 8) {
                Text(units.displayName)
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.20), in: Capsule())

                if let lastUpdated {
                    Text("Updated \(WeatherFormatters.updatedString(from: lastUpdated))")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            .foregroundStyle(AppTheme.primaryText)

            if let timezone, !timezone.isEmpty {
                Text(timezone.replacingOccurrences(of: "_", with: " "))
                    .font(.system(.footnote, design: .rounded, weight: .medium))
                    .foregroundStyle(AppTheme.secondaryText)
            }

            if let coordinates {
                Text(String(format: "Lat %.3f • Lon %.3f", coordinates.lat, coordinates.lon))
                    .font(.system(.footnote, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)
            }
        }
        .glassCard()
    }
}
