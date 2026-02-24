import SwiftUI

struct CurrentWeatherCard: View {
    let weather: CurrentWeather
    let timezoneOffset: Int
    let units: WeatherUnits

    private var primaryCondition: WeatherCondition? { weather.weather.first }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Current")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)

            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(WeatherFormatters.temperature(weather.temp, units: units))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.primaryText)

                    Text("Feels like \(WeatherFormatters.temperature(weather.feelsLike, units: units))")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(AppTheme.secondaryText)

                    Text(primaryCondition?.description.capitalized ?? "")
                        .font(.system(.body, design: .rounded, weight: .medium))
                        .foregroundStyle(AppTheme.primaryText)
                }

                Spacer(minLength: 8)

                WeatherIconView(iconCode: primaryCondition?.icon ?? "01d", size: 86)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                metricItem(title: "Humidity", value: "\(weather.humidity)%")
                metricItem(title: "Pressure", value: WeatherFormatters.pressure(weather.pressure))
                metricItem(title: "Visibility", value: WeatherFormatters.visibility(weather.visibility, units: units))
                metricItem(title: "Clouds", value: "\(weather.clouds)%")
                metricItem(title: "Dew Point", value: WeatherFormatters.temperature(weather.dewPoint, units: units))
                metricItem(title: "UV Index", value: weather.uvi.map { String(format: "%.1f", $0) } ?? "--")
                metricItem(
                    title: "Wind",
                    value: "\(WeatherFormatters.wind(weather.windSpeed, units: units)) \(WeatherFormatters.windDirection(from: weather.windDeg))"
                )

                let gustText = weather.windGust.map {
                    WeatherFormatters.wind($0, units: units)
                } ?? "--"
                metricItem(title: "Wind Gust", value: gustText)

                let rainText = weather.rain.map {
                    WeatherFormatters.precipitation($0.oneHour, units: units)
                } ?? "--"
                metricItem(title: "Rain (1h)", value: rainText)

                let snowText = weather.snow.map {
                    WeatherFormatters.precipitation($0.oneHour, units: units)
                } ?? "--"
                metricItem(title: "Snow (1h)", value: snowText)
            }

            HStack(spacing: 12) {
                let sunrise = weather.sunrise.map {
                    WeatherFormatters.timeString(unix: $0, timezoneOffset: timezoneOffset, format: "HH:mm")
                } ?? "--"
                let sunset = weather.sunset.map {
                    WeatherFormatters.timeString(unix: $0, timezoneOffset: timezoneOffset, format: "HH:mm")
                } ?? "--"

                metricItem(title: "Sunrise", value: sunrise)
                metricItem(title: "Sunset", value: sunset)
            }
        }
        .glassCard()
    }

    @ViewBuilder
    private func metricItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(AppTheme.secondaryText)
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(AppTheme.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
