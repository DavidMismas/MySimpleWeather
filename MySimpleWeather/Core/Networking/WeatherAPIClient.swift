import Foundation

protocol WeatherAPIClient {
    func fetchWeather(lat: Double, lon: Double, units: WeatherUnits, language: String) async throws -> OneCallResponse
    func searchCities(query: String, limit: Int) async throws -> [GeoLocation]
    func reverseGeocode(lat: Double, lon: Double, limit: Int) async throws -> [GeoLocation]
}

enum WeatherAPIError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case transport(Error)
    case server(statusCode: Int, message: String?)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your OpenWeather key in OpenWeatherSecrets.swift."
        case .invalidURL:
            return "Could not build request URL."
        case .transport(let error):
            return error.localizedDescription
        case .server(let statusCode, let message):
            if let message, !message.isEmpty {
                return "OpenWeather error (\(statusCode)): \(message)"
            }
            return "OpenWeather request failed (\(statusCode))."
        case .decoding:
            return "Could not decode weather data from OpenWeather."
        }
    }
}
