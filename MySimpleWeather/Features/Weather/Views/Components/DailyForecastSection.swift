import SwiftUI

struct DailyForecastSection: View {
    let items: [DailyWeather]
    let timezoneOffset: Int
    let units: WeatherUnits
    private let columns = [
        GridItem(.flexible(), spacing: 8, alignment: .topLeading),
        GridItem(.flexible(), spacing: 8, alignment: .topLeading)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Forecast")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)

            VStack(spacing: 10) {
                ForEach(items) { day in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 12) {
                            Text(WeatherFormatters.timeString(unix: day.dt, timezoneOffset: timezoneOffset, format: "EEE"))
                                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                .foregroundStyle(AppTheme.primaryText)
                                .frame(width: 42, alignment: .leading)

                            WeatherIconView(iconCode: day.weather.first?.icon ?? "01d", size: 36)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(day.weather.first?.description.capitalized ?? "")
                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    .foregroundStyle(AppTheme.primaryText)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Rain: \(WeatherFormatters.percent(day.pop))")
                                    if let summary = day.summary, !summary.isEmpty {
                                        Text(summary)
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(AppTheme.secondaryText)
                            }

                            Spacer(minLength: 8)

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(WeatherFormatters.temperature(day.temp.max, units: units))
                                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                                    .foregroundStyle(AppTheme.primaryText)
                                Text(WeatherFormatters.temperature(day.temp.min, units: units))
                                    .font(.system(.caption, design: .rounded, weight: .medium))
                                    .foregroundStyle(AppTheme.secondaryText)
                            }
                        }

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(metrics(for: day)) { metric in
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(metric.title)
                                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                                        .foregroundStyle(AppTheme.secondaryText.opacity(0.92))

                                    Text(metric.value)
                                        .font(.system(.caption, design: .rounded, weight: .medium))
                                        .foregroundStyle(AppTheme.primaryText)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.85)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .frame(maxWidth: .infinity, minHeight: 46, alignment: .leading)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 7)
                                .background(
                                    Color.white.opacity(0.10),
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                                )
                            }
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .glassCard()
    }

    private func metrics(for day: DailyWeather) -> [DailyMetric] {
        let sunrise = day.sunrise.map {
            WeatherFormatters.timeString(unix: $0, timezoneOffset: timezoneOffset, format: "HH:mm")
        } ?? "--"
        let sunset = day.sunset.map {
            WeatherFormatters.timeString(unix: $0, timezoneOffset: timezoneOffset, format: "HH:mm")
        } ?? "--"
        let moonrise = day.moonrise.map {
            WeatherFormatters.timeString(unix: $0, timezoneOffset: timezoneOffset, format: "HH:mm")
        } ?? "--"
        let moonset = day.moonset.map {
            WeatherFormatters.timeString(unix: $0, timezoneOffset: timezoneOffset, format: "HH:mm")
        } ?? "--"
        let moonPhase = String(format: "%.2f", day.moonPhase)
        let uv = String(format: "%.1f", day.uvi)
        let gust = day.windGust.map { WeatherFormatters.wind($0, units: units) } ?? "--"

        var metrics: [DailyMetric] = [
            DailyMetric(title: "Rain Chance", value: WeatherFormatters.percent(day.pop)),
            DailyMetric(title: "Humidity", value: "\(day.humidity)%"),
            DailyMetric(
                title: "Wind",
                value: "\(WeatherFormatters.wind(day.windSpeed, units: units)) \(WeatherFormatters.windDirection(from: day.windDeg))"
            ),
            DailyMetric(title: "Wind Gust", value: gust),
            DailyMetric(title: "UV", value: uv),
            DailyMetric(title: "Pressure", value: "\(day.pressure) hPa"),
            DailyMetric(title: "Clouds", value: "\(day.clouds)%"),
            DailyMetric(title: "Dew Point", value: WeatherFormatters.temperature(day.dewPoint, units: units)),
            DailyMetric(title: "Sun", value: "\(sunrise) - \(sunset)"),
            DailyMetric(title: "Moonrise / Set", value: "\(moonrise) / \(moonset)"),
            DailyMetric(title: "Moon Phase", value: moonPhase),
            DailyMetric(
                title: "Day / Night",
                value: "\(WeatherFormatters.temperature(day.temp.day, units: units)) / \(WeatherFormatters.temperature(day.temp.night, units: units))"
            ),
            DailyMetric(
                title: "Feels Day / Night",
                value: "\(WeatherFormatters.temperature(day.feelsLike.day, units: units)) / \(WeatherFormatters.temperature(day.feelsLike.night, units: units))"
            )
        ]

        if let rain = day.rain {
            metrics.append(DailyMetric(title: "Rain Amount", value: WeatherFormatters.precipitation(rain, units: units)))
        }
        if let snow = day.snow {
            metrics.append(DailyMetric(title: "Snow Amount", value: WeatherFormatters.precipitation(snow, units: units)))
        }

        return metrics
    }
}

private struct DailyMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
}
