import CoreLocation
import Combine
import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    @Published var weather: OneCallResponse?
    @Published var locationName: String = "Loading…"
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    @Published var searchText = ""
    @Published var searchResults: [GeoLocation] = []
    @Published var searchErrorMessage: String?
    @Published var isSearching = false

    @Published var isSearchSheetPresented = false
    @Published var isSettingsPresented = false

    @Published var units: WeatherUnits
    @Published var showMinutely: Bool
    @Published var lastUpdated: Date?
    @Published var defaultLocation: GeoLocation?

    private let apiClient: WeatherAPIClient
    private let locationService: LocationProviding
    private let placeNameResolver: PlaceNameResolving
    private let settingsStore: AppSettingsStore
    private let cacheStore: WeatherCacheStore
    private let widgetSharedStore: WidgetSharedStore

    private var searchTask: Task<Void, Never>?
    private var lastFetchAtByLocation: [String: Date] = [:]

    private(set) var selectedCity: GeoLocation?
    private var currentDeviceCoordinates: CLLocationCoordinate2D?

    private let minimumRefreshInterval: TimeInterval = 600

    init(
        apiClient: WeatherAPIClient,
        locationService: LocationProviding,
        settingsStore: AppSettingsStore,
        cacheStore: WeatherCacheStore,
        placeNameResolver: PlaceNameResolving,
        widgetSharedStore: WidgetSharedStore
    ) {
        self.apiClient = apiClient
        self.locationService = locationService
        self.settingsStore = settingsStore
        self.cacheStore = cacheStore
        self.placeNameResolver = placeNameResolver
        self.widgetSharedStore = widgetSharedStore
        self.units = settingsStore.units
        self.showMinutely = settingsStore.showMinutely
        self.defaultLocation = settingsStore.defaultLocation

        locationService.onAuthorizationChange = { [weak self] status in
            Task { @MainActor in
                self?.handleAuthorization(status)
            }
        }

        locationService.onLocationChange = { [weak self] location in
            Task { @MainActor in
                await self?.handleLocationUpdate(location)
            }
        }

        locationService.onError = { [weak self] error in
            Task { @MainActor in
                self?.errorMessage = error.localizedDescription
            }
        }

        restoreCachedWeatherIfAvailable()
    }

    var hasWeather: Bool { weather != nil }

    var hourlyForecast: [HourlyWeather] {
        Array((weather?.hourly ?? []).prefix(24))
    }

    var dailyForecast: [DailyWeather] {
        Array((weather?.daily ?? []).prefix(8))
    }

    var minutelyForecast: [MinutelyWeather] {
        Array((weather?.minutely ?? []).prefix(60))
    }

    var alerts: [WeatherAlert] {
        weather?.alerts ?? []
    }

    func onAppear() {
        if weather == nil {
            startInitialLoad()
        }
    }

    func startInitialLoad() {
        if let defaultLocation {
            Task {
                await loadWeather(
                    lat: defaultLocation.lat,
                    lon: defaultLocation.lon,
                    displayName: defaultLocation.displayName,
                    selectedCity: defaultLocation,
                    force: false
                )
            }
            return
        }

        switch locationService.authorizationStatus {
        case .notDetermined:
            locationService.requestPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            locationService.requestLocation()
        case .denied, .restricted:
            if weather == nil {
                locationName = "Location Access Needed"
            }
            errorMessage = "Location access is disabled. Search for a city or enable location access in Settings."
        @unknown default:
            errorMessage = "Unknown location authorization state."
        }
    }

    func refresh(force: Bool = false) {
        if let selectedCity {
            Task {
                await loadWeather(
                    lat: selectedCity.lat,
                    lon: selectedCity.lon,
                    displayName: selectedCity.displayName,
                    selectedCity: selectedCity,
                    force: force
                )
            }
            return
        }

        if let currentDeviceCoordinates {
            Task {
                await loadWeather(
                    lat: currentDeviceCoordinates.latitude,
                    lon: currentDeviceCoordinates.longitude,
                    displayName: nil,
                    selectedCity: nil,
                    force: force
                )
            }
            return
        }

        startInitialLoad()
    }

    func useMyLocation() {
        selectedCity = nil
        isSearchSheetPresented = false

        switch locationService.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationService.requestLocation()
        case .notDetermined:
            locationService.requestPermission()
        default:
            errorMessage = "Location access is disabled."
        }
    }

    func setUnits(_ newValue: WeatherUnits) {
        guard units != newValue else { return }
        units = newValue
        settingsStore.units = newValue
        refresh(force: true)
    }

    func setShowMinutely(_ isEnabled: Bool) {
        showMinutely = isEnabled
        settingsStore.showMinutely = isEnabled
    }

    func saveCurrentLocationAsDefault() {
        guard let weather else { return }

        let candidate = selectedCity ?? GeoLocation(
            name: locationName,
            lat: weather.lat,
            lon: weather.lon,
            country: "",
            state: nil
        )

        defaultLocation = candidate
        settingsStore.defaultLocation = candidate
    }

    func useDefaultLocationNow() {
        guard let defaultLocation else { return }
        Task {
            await loadWeather(
                lat: defaultLocation.lat,
                lon: defaultLocation.lon,
                displayName: defaultLocation.displayName,
                selectedCity: defaultLocation,
                force: true
            )
        }
    }

    func clearDefaultLocation() {
        defaultLocation = nil
        settingsStore.defaultLocation = nil
    }

    func updateSearch(text: String) {
        searchText = text
        searchErrorMessage = nil
        searchTask?.cancel()

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            isSearching = false
            searchResults = []
            return
        }

        isSearching = true
        searchTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 400_000_000)
            guard !Task.isCancelled, let self else { return }

            do {
                let results = try await apiClient.searchCities(query: trimmed, limit: 5)
                guard !Task.isCancelled else { return }
                self.searchResults = results
                self.isSearching = false
            } catch {
                guard !Task.isCancelled else { return }
                self.searchErrorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                self.searchResults = []
                self.isSearching = false
            }
        }
    }

    func selectSearchResult(_ location: GeoLocation) {
        selectedCity = location
        isSearchSheetPresented = false
        searchText = ""
        searchResults = []

        Task {
            await loadWeather(
                lat: location.lat,
                lon: location.lon,
                displayName: location.displayName,
                selectedCity: location,
                force: true
            )
        }
    }

    private func restoreCachedWeatherIfAvailable() {
        guard let cached = cacheStore.load() else { return }
        weather = cached.response
        locationName = cached.placeName
        lastUpdated = cached.fetchedAt
        widgetSharedStore.save(
            response: cached.response,
            locationName: cached.placeName,
            units: cached.units,
            updatedAt: cached.fetchedAt
        )

        if cached.location.country.isEmpty {
            selectedCity = nil
        } else {
            selectedCity = cached.location
        }
    }

    private func handleAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationService.requestLocation()
        case .denied, .restricted:
            if weather == nil {
                locationName = "Location Access Needed"
            }
            errorMessage = "Location access is disabled. Search by city to continue."
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    private func handleLocationUpdate(_ location: CLLocation) async {
        currentDeviceCoordinates = location.coordinate
        await loadWeather(
            lat: location.coordinate.latitude,
            lon: location.coordinate.longitude,
            displayName: nil,
            selectedCity: nil,
            force: false
        )
    }

    private func loadWeather(
        lat: Double,
        lon: Double,
        displayName: String?,
        selectedCity: GeoLocation?,
        force: Bool
    ) async {
        let cacheKey = String(format: "%.3f,%.3f,%@", lat, lon, units.rawValue)
        let now = Date()

        if !force,
           let lastFetch = lastFetchAtByLocation[cacheKey],
           now.timeIntervalSince(lastFetch) < minimumRefreshInterval {
            return
        }

        if weather == nil {
            isLoading = true
        } else {
            isRefreshing = true
        }
        errorMessage = nil

        do {
            let languageCode = Locale.current.language.languageCode?.identifier ?? "en"
            async let weatherRequest = apiClient.fetchWeather(
                lat: lat,
                lon: lon,
                units: units,
                language: languageCode
            )

            let resolvedName: String
            if let displayName {
                resolvedName = displayName
            } else {
                resolvedName = await placeNameResolver.resolveName(lat: lat, lon: lon) ?? "Current Location"
            }

            let response = try await weatherRequest
            weather = response
            locationName = resolvedName
            lastUpdated = now
            self.selectedCity = selectedCity
            lastFetchAtByLocation[cacheKey] = now

            let cacheLocation = selectedCity ?? GeoLocation(
                name: resolvedName,
                lat: lat,
                lon: lon,
                country: "",
                state: nil
            )
            cacheStore.save(
                CachedWeatherPayload(
                    location: cacheLocation,
                    placeName: resolvedName,
                    units: units,
                    fetchedAt: now,
                    response: response
                )
            )
            widgetSharedStore.save(
                response: response,
                locationName: resolvedName,
                units: units,
                updatedAt: now
            )
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
        isRefreshing = false
    }
}
