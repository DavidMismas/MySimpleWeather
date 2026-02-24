import Foundation

enum WeatherUnits: String, CaseIterable, Codable, Identifiable {
    case metric
    case imperial

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .metric: return "Metric"
        case .imperial: return "Imperial"
        }
    }

    var temperatureUnit: String {
        switch self {
        case .metric: return "C"
        case .imperial: return "F"
        }
    }

    var windSpeedUnit: String {
        switch self {
        case .metric: return "m/s"
        case .imperial: return "mph"
        }
    }

    var distanceUnit: String {
        switch self {
        case .metric: return "km"
        case .imperial: return "mi"
        }
    }

    var precipitationUnit: String {
        "mm/h"
    }
}
