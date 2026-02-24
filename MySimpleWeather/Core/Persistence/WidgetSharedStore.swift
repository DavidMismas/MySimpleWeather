import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

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

final class WidgetSharedStore {
    static let shared = WidgetSharedStore()

    private let defaults: UserDefaults?

    init(defaults: UserDefaults? = UserDefaults(suiteName: SharedAppGroup.identifier)) {
        self.defaults = defaults
    }

    func save(
        response: OneCallResponse,
        locationName: String,
        units: WeatherUnits,
        updatedAt: Date
    ) {
        guard let defaults else { return }

        let snapshot = WidgetWeatherSnapshot(
            locationName: locationName,
            timezoneOffset: response.timezoneOffset,
            updatedAt: updatedAt,
            unitsRaw: units.rawValue,
            currentTemp: response.current.temp,
            feelsLike: response.current.feelsLike,
            conditionDescription: response.current.weather.first?.description ?? "",
            conditionIcon: response.current.weather.first?.icon ?? "01d",
            humidity: response.current.humidity,
            windSpeed: response.current.windSpeed,
            windDeg: response.current.windDeg,
            currentRainOneHour: response.current.rain?.oneHour,
            currentSnowOneHour: response.current.snow?.oneHour,
            nextHourPrecipitationTotal: (response.minutely ?? []).prefix(60).reduce(0) { $0 + $1.precipitation },
            daily: response.daily.prefix(7).map {
                WidgetDailyForecastSnapshot(
                    dt: $0.dt,
                    minTemp: $0.temp.min,
                    maxTemp: $0.temp.max,
                    pop: $0.pop,
                    rain: $0.rain,
                    snow: $0.snow,
                    icon: $0.weather.first?.icon ?? "01d"
                )
            }
        )

        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: SharedAppGroup.widgetSnapshotKey)

        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "SimpleWidget")
        #endif
    }
}
