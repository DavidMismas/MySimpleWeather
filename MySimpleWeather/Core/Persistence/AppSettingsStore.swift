import Foundation

final class AppSettingsStore {
    static let shared = AppSettingsStore()

    private let defaults: UserDefaults

    private enum Keys {
        static let units = "weather_units"
        static let showMinutely = "show_minutely"
        static let defaultLocation = "default_location"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var units: WeatherUnits {
        get {
            guard let rawValue = defaults.string(forKey: Keys.units),
                  let units = WeatherUnits(rawValue: rawValue) else {
                return .metric
            }
            return units
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.units)
        }
    }

    var showMinutely: Bool {
        get {
            guard defaults.object(forKey: Keys.showMinutely) != nil else {
                return true
            }
            return defaults.bool(forKey: Keys.showMinutely)
        }
        set {
            defaults.set(newValue, forKey: Keys.showMinutely)
        }
    }

    var defaultLocation: GeoLocation? {
        get {
            guard let data = defaults.data(forKey: Keys.defaultLocation) else {
                return nil
            }
            return try? JSONDecoder().decode(GeoLocation.self, from: data)
        }
        set {
            if let newValue, let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Keys.defaultLocation)
            } else {
                defaults.removeObject(forKey: Keys.defaultLocation)
            }
        }
    }
}
