import SwiftUI

@main
struct MySimpleWeatherApp: App {
    @StateObject private var viewModel: WeatherViewModel

    init() {
        let apiClient = OpenWeatherAPIClient()
        let locationService = LocationService()
        let settingsStore = AppSettingsStore.shared
        let cacheStore = WeatherCacheStore.shared
        let widgetSharedStore = WidgetSharedStore.shared
        let placeNameResolver = PlaceNameResolver(apiClient: apiClient)

        _viewModel = StateObject(
            wrappedValue: WeatherViewModel(
                apiClient: apiClient,
                locationService: locationService,
                settingsStore: settingsStore,
                cacheStore: cacheStore,
                placeNameResolver: placeNameResolver,
                widgetSharedStore: widgetSharedStore
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .preferredColorScheme(.dark)
        }
    }
}
