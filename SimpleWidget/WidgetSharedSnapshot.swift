import Foundation

enum SharedAppGroup {
    static let identifier = "group.com.david.MySimpleWeather.shared"
    static let widgetSnapshotKey = "widget_weather_snapshot"
}

struct WidgetDailyForecastSnapshot: Codable, Identifiable {
    let dt: Int
    let minTemp: Double
    let maxTemp: Double
    let pop: Double
    let rain: Double?
    let snow: Double?
    let icon: String

    var id: Int { dt }
}

struct WidgetWeatherSnapshot: Codable {
    let locationName: String
    let timezoneOffset: Int
    let updatedAt: Date
    let unitsRaw: String
    let currentTemp: Double
    let feelsLike: Double
    let conditionDescription: String
    let conditionIcon: String
    let humidity: Int
    let windSpeed: Double
    let windDeg: Int
    let currentRainOneHour: Double?
    let currentSnowOneHour: Double?
    let nextHourPrecipitationTotal: Double
    let daily: [WidgetDailyForecastSnapshot]
}

final class WidgetSnapshotReader {
    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = UserDefaults(suiteName: SharedAppGroup.identifier)) {
        self.defaults = defaults
    }

    func load() -> WidgetWeatherSnapshot? {
        guard let defaults,
              let data = defaults.data(forKey: SharedAppGroup.widgetSnapshotKey) else {
            return nil
        }

        return try? JSONDecoder().decode(WidgetWeatherSnapshot.self, from: data)
    }
}

extension WidgetWeatherSnapshot {
    static let preview = WidgetWeatherSnapshot(
        locationName: "San Francisco, US",
        timezoneOffset: -28800,
        updatedAt: .now,
        unitsRaw: "metric",
        currentTemp: 17,
        feelsLike: 16,
        conditionDescription: "light rain",
        conditionIcon: "10d",
        humidity: 74,
        windSpeed: 4.2,
        windDeg: 240,
        currentRainOneHour: 1.2,
        currentSnowOneHour: nil,
        nextHourPrecipitationTotal: 2.6,
        daily: [
            WidgetDailyForecastSnapshot(dt: Int(Date().timeIntervalSince1970), minTemp: 12, maxTemp: 18, pop: 0.6, rain: 2.4, snow: nil, icon: "10d"),
            WidgetDailyForecastSnapshot(dt: Int(Date().addingTimeInterval(86400).timeIntervalSince1970), minTemp: 11, maxTemp: 17, pop: 0.4, rain: 1.3, snow: nil, icon: "04d"),
            WidgetDailyForecastSnapshot(dt: Int(Date().addingTimeInterval(172800).timeIntervalSince1970), minTemp: 10, maxTemp: 16, pop: 0.2, rain: nil, snow: nil, icon: "03d"),
            WidgetDailyForecastSnapshot(dt: Int(Date().addingTimeInterval(259200).timeIntervalSince1970), minTemp: 9, maxTemp: 15, pop: 0.15, rain: nil, snow: nil, icon: "02d"),
            WidgetDailyForecastSnapshot(dt: Int(Date().addingTimeInterval(345600).timeIntervalSince1970), minTemp: 8, maxTemp: 14, pop: 0.10, rain: nil, snow: nil, icon: "01d")
        ]
    )
}
