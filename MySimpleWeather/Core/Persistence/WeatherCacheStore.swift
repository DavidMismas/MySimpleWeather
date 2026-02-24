import Foundation

struct CachedWeatherPayload: Codable {
    let location: GeoLocation
    let placeName: String
    let units: WeatherUnits
    let fetchedAt: Date
    let response: OneCallResponse
}

final class WeatherCacheStore {
    static let shared = WeatherCacheStore()

    private let defaults: UserDefaults
    private let cacheKey = "cached_weather_payload"

    private var inMemoryCache: CachedWeatherPayload?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> CachedWeatherPayload? {
        if let inMemoryCache {
            return inMemoryCache
        }

        guard let data = defaults.data(forKey: cacheKey) else {
            return nil
        }

        do {
            let payload = try JSONDecoder().decode(CachedWeatherPayload.self, from: data)
            inMemoryCache = payload
            return payload
        } catch {
            return nil
        }
    }

    func save(_ payload: CachedWeatherPayload) {
        inMemoryCache = payload
        do {
            let data = try JSONEncoder().encode(payload)
            defaults.set(data, forKey: cacheKey)
        } catch {
            defaults.removeObject(forKey: cacheKey)
        }
    }
}
