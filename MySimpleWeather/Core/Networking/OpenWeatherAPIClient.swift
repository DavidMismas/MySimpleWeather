import Foundation

final class OpenWeatherAPIClient: WeatherAPIClient {
    private let session: URLSession
    private let apiKeyProvider: () -> String
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        apiKeyProvider: @escaping () -> String = { OpenWeatherSecrets.apiKey }
    ) {
        self.session = session
        self.apiKeyProvider = apiKeyProvider
        self.decoder = JSONDecoder()
    }

    func fetchWeather(lat: Double, lon: Double, units: WeatherUnits, language: String) async throws -> OneCallResponse {
        let items = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: try validatedAPIKey()),
            URLQueryItem(name: "units", value: units.rawValue),
            URLQueryItem(name: "lang", value: language)
        ]
        let request = try makeRequest(path: "/data/3.0/onecall", queryItems: items)
        return try await execute(request, as: OneCallResponse.self)
    }

    func searchCities(query: String, limit: Int) async throws -> [GeoLocation] {
        let items = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "appid", value: try validatedAPIKey())
        ]
        let request = try makeRequest(path: "/geo/1.0/direct", queryItems: items)
        let response = try await execute(request, as: [GeocodingLocationResponse].self)
        return response.map { $0.asGeoLocation() }
    }

    func reverseGeocode(lat: Double, lon: Double, limit: Int) async throws -> [GeoLocation] {
        let items = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "appid", value: try validatedAPIKey())
        ]
        let request = try makeRequest(path: "/geo/1.0/reverse", queryItems: items)
        let response = try await execute(request, as: [GeocodingLocationResponse].self)
        return response.map { $0.asGeoLocation() }
    }

    private func validatedAPIKey() throws -> String {
        let key = apiKeyProvider().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !key.isEmpty, key != "PUT_KEY_HERE" else {
            throw WeatherAPIError.missingAPIKey
        }
        return key
    }

    private func makeRequest(path: String, queryItems: [URLQueryItem]) throws -> URLRequest {
        guard var components = URLComponents(string: "https://api.openweathermap.org\(path)") else {
            throw WeatherAPIError.invalidURL
        }
        components.queryItems = queryItems
        guard let url = components.url else {
            throw WeatherAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 20
        return request
    }

    private func execute<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw WeatherAPIError.transport(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherAPIError.transport(URLError(.badServerResponse))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiMessage = (try? decoder.decode(OpenWeatherErrorBody.self, from: data))?.message
            throw WeatherAPIError.server(statusCode: httpResponse.statusCode, message: apiMessage)
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw WeatherAPIError.decoding(error)
        }
    }
}

private struct OpenWeatherErrorBody: Decodable {
    let cod: String?
    let message: String?
}
