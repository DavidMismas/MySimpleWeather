import Foundation

enum WeatherFormatters {
    static func temperature(_ value: Double, units: WeatherUnits) -> String {
        "\(Int(value.rounded()))°\(units.temperatureUnit)"
    }

    static func wind(_ value: Double, units: WeatherUnits) -> String {
        String(format: "%.1f %@", value, units.windSpeedUnit)
    }

    static func visibility(_ meters: Int?, units: WeatherUnits) -> String {
        guard let meters else { return "--" }
        switch units {
        case .metric:
            return String(format: "%.1f %@", Double(meters) / 1000.0, units.distanceUnit)
        case .imperial:
            return String(format: "%.1f %@", Double(meters) / 1609.344, units.distanceUnit)
        }
    }

    static func pressure(_ hPa: Int) -> String {
        "\(hPa) hPa"
    }

    static func precipitation(_ value: Double, units: WeatherUnits) -> String {
        String(format: "%.1f %@", value, units.precipitationUnit)
    }

    static func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    static func timeString(unix: Int, timezoneOffset: Int, format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unix + timezoneOffset))
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    static func updatedString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func windDirection(from degrees: Int) -> String {
        let directions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "N"]
        let index = Int((Double(degrees).truncatingRemainder(dividingBy: 360) / 45.0).rounded())
        return directions[min(max(index, 0), directions.count - 1)]
    }
}
