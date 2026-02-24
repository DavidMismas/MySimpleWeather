import CoreLocation
import Foundation

protocol PlaceNameResolving {
    func resolveName(lat: Double, lon: Double) async -> String?
}

final class PlaceNameResolver: PlaceNameResolving {
    private let apiClient: WeatherAPIClient
    private let geocoder = CLGeocoder()

    init(apiClient: WeatherAPIClient) {
        self.apiClient = apiClient
    }

    func resolveName(lat: Double, lon: Double) async -> String? {
        if let geo = try? await apiClient.reverseGeocode(lat: lat, lon: lon, limit: 1).first {
            return geo.displayName
        }

        let location = CLLocation(latitude: lat, longitude: lon)
        guard let placemark = try? await geocoder.reverseGeocodeLocation(location).first else {
            return nil
        }

        let city = placemark.locality ?? placemark.name
        let country = placemark.country
        return [city, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}
