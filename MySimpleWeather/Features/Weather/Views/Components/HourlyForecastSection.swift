import SwiftUI

struct HourlyForecastSection: View {
    let items: [HourlyWeather]
    let timezoneOffset: Int
    let units: WeatherUnits

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hourly Forecast")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(items) { hour in
                        VStack(spacing: 8) {
                            Text(WeatherFormatters.timeString(unix: hour.dt, timezoneOffset: timezoneOffset, format: "HH:mm"))
                                .font(.system(.caption, design: .rounded, weight: .medium))
                                .foregroundStyle(AppTheme.secondaryText)

                            WeatherIconView(iconCode: hour.weather.first?.icon ?? "01d", size: 40)

                            Text(WeatherFormatters.temperature(hour.temp, units: units))
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                .foregroundStyle(AppTheme.primaryText)

                            Text("Feels \(WeatherFormatters.temperature(hour.feelsLike, units: units))")
                                .font(.system(.caption2, design: .rounded, weight: .semibold))
                                .foregroundStyle(AppTheme.secondaryText)

                            VStack(alignment: .leading, spacing: 4) {
                                metricRow(title: "Rain", value: WeatherFormatters.percent(hour.pop))
                                metricRow(title: "Hum", value: "\(hour.humidity)%")
                                metricRow(
                                    title: "Wind",
                                    value: "\(WeatherFormatters.wind(hour.windSpeed, units: units)) \(WeatherFormatters.windDirection(from: hour.windDeg))"
                                )
                                metricRow(title: "UV", value: String(format: "%.1f", hour.uvi))
                                metricRow(title: "Clouds", value: "\(hour.clouds)%")
                                metricRow(title: "Pressure", value: "\(hour.pressure) hPa")

                                if let rain = hour.rain?.oneHour {
                                    metricRow(title: "Rain 1h", value: WeatherFormatters.precipitation(rain, units: units))
                                }

                                if let snow = hour.snow?.oneHour {
                                    metricRow(title: "Snow 1h", value: WeatherFormatters.precipitation(snow, units: units))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 10)
                        .frame(width: 132)
                        .background(Color.white.opacity(0.13), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                }
            }
        }
        .glassCard()
    }

    private func metricRow(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(title)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)
            Spacer(minLength: 2)
            Text(value)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
    }
}
