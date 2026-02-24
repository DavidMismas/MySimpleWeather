import Foundation

struct OneCallResponse: Codable {
    let lat: Double
    let lon: Double
    let timezone: String
    let timezoneOffset: Int
    let current: CurrentWeather
    let minutely: [MinutelyWeather]?
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
    let alerts: [WeatherAlert]?

    enum CodingKeys: String, CodingKey {
        case lat
        case lon
        case timezone
        case timezoneOffset = "timezone_offset"
        case current
        case minutely
        case hourly
        case daily
        case alerts
    }
}

struct WeatherCondition: Codable, Hashable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct CurrentWeather: Codable {
    let dt: Int
    let sunrise: Int?
    let sunset: Int?
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let uvi: Double?
    let clouds: Int
    let visibility: Int?
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double?
    let weather: [WeatherCondition]
    let rain: PrecipitationVolume?
    let snow: PrecipitationVolume?

    enum CodingKeys: String, CodingKey {
        case dt
        case sunrise
        case sunset
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case dewPoint = "dew_point"
        case uvi
        case clouds
        case visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather
        case rain
        case snow
    }
}

struct MinutelyWeather: Codable {
    let dt: Int
    let precipitation: Double
}

struct HourlyWeather: Codable, Identifiable {
    let dt: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let uvi: Double
    let clouds: Int
    let visibility: Int?
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double?
    let weather: [WeatherCondition]
    let pop: Double
    let rain: PrecipitationVolume?
    let snow: PrecipitationVolume?

    var id: Int { dt }

    enum CodingKeys: String, CodingKey {
        case dt
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case dewPoint = "dew_point"
        case uvi
        case clouds
        case visibility
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather
        case pop
        case rain
        case snow
    }
}

struct DailyWeather: Codable, Identifiable {
    let dt: Int
    let sunrise: Int?
    let sunset: Int?
    let moonrise: Int?
    let moonset: Int?
    let moonPhase: Double
    let summary: String?
    let temp: DailyTemperature
    let feelsLike: DailyFeelsLike
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let windSpeed: Double
    let windDeg: Int
    let windGust: Double?
    let weather: [WeatherCondition]
    let clouds: Int
    let pop: Double
    let rain: Double?
    let snow: Double?
    let uvi: Double

    var id: Int { dt }

    enum CodingKeys: String, CodingKey {
        case dt
        case sunrise
        case sunset
        case moonrise
        case moonset
        case moonPhase = "moon_phase"
        case summary
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case dewPoint = "dew_point"
        case windSpeed = "wind_speed"
        case windDeg = "wind_deg"
        case windGust = "wind_gust"
        case weather
        case clouds
        case pop
        case rain
        case snow
        case uvi
    }
}

struct DailyTemperature: Codable {
    let morn: Double
    let day: Double
    let eve: Double
    let night: Double
    let min: Double
    let max: Double
}

struct DailyFeelsLike: Codable {
    let morn: Double
    let day: Double
    let eve: Double
    let night: Double
}

struct PrecipitationVolume: Codable {
    let oneHour: Double

    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
    }
}

struct WeatherAlert: Codable, Identifiable {
    let senderName: String
    let event: String
    let start: Int
    let end: Int
    let description: String
    let tags: [String]?

    var id: String { "\(event)-\(start)-\(senderName)" }

    enum CodingKeys: String, CodingKey {
        case senderName = "sender_name"
        case event
        case start
        case end
        case description
        case tags
    }
}
