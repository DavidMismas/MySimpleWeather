import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        WeatherScreen(viewModel: viewModel)
    }
}

#Preview {
    let apiClient = OpenWeatherAPIClient(apiKeyProvider: { "preview" })
    let viewModel = WeatherViewModel(
        apiClient: apiClient,
        locationService: LocationService(),
        settingsStore: AppSettingsStore(),
        cacheStore: WeatherCacheStore(),
        placeNameResolver: PlaceNameResolver(apiClient: apiClient),
        widgetSharedStore: WidgetSharedStore()
    )
    return ContentView(viewModel: viewModel)
}
