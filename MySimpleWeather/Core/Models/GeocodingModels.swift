import Foundation

struct GeoLocation: Codable, Hashable, Identifiable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    var id: String {
        "\(name)|\(lat)|\(lon)|\(country)|\(state ?? "")"
    }

    var displayName: String {
        [name, state, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

struct GeocodingLocationResponse: Decodable {
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat
        case lon
        case country
        case state
    }

    func asGeoLocation() -> GeoLocation {
        GeoLocation(name: name, lat: lat, lon: lon, country: country, state: state)
    }
}
