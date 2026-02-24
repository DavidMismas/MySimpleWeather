import SwiftUI

struct WeatherScreen: View {
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                decorativeBackground

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        WeatherHeaderCard(
                            locationName: viewModel.locationName,
                            timezone: viewModel.weather?.timezone,
                            coordinates: viewModel.weather.map { (lat: $0.lat, lon: $0.lon) },
                            lastUpdated: viewModel.lastUpdated,
                            units: viewModel.units
                        )

                        if let weather = viewModel.weather {
                            if let errorMessage = viewModel.errorMessage {
                                inlineError(message: errorMessage)
                            }

                            CurrentWeatherCard(
                                weather: weather.current,
                                timezoneOffset: weather.timezoneOffset,
                                units: viewModel.units
                            )

                            if viewModel.showMinutely {
                                MinutelySectionView(
                                    items: viewModel.minutelyForecast,
                                    units: viewModel.units
                                )
                            }

                            HourlyForecastSection(
                                items: viewModel.hourlyForecast,
                                timezoneOffset: weather.timezoneOffset,
                                units: viewModel.units
                            )

                            DailyForecastSection(
                                items: viewModel.dailyForecast,
                                timezoneOffset: weather.timezoneOffset,
                                units: viewModel.units
                            )

                            AlertsSectionView(
                                alerts: viewModel.alerts,
                                timezoneOffset: weather.timezoneOffset
                            )
                        } else if viewModel.isLoading {
                            LoadingSkeletonView()
                        } else {
                            EmptyStateView(
                                title: "No Weather Yet",
                                message: "Allow location access or search for a city to load weather.",
                                buttonTitle: "Retry"
                            ) {
                                viewModel.startInitialLoad()
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                }
                .refreshable {
                    viewModel.refresh(force: true)
                }
                .animation(.easeInOut(duration: 0.28), value: viewModel.weather?.current.dt ?? 0)
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.useMyLocation()
                    } label: {
                        Image(systemName: "location.fill")
                    }
                    .tint(.white)
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        viewModel.isSearchSheetPresented = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .tint(.white)

                    Button {
                        viewModel.isSettingsPresented = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                    .tint(.white)
                }
            }
            .task {
                viewModel.onAppear()
            }
            .sheet(isPresented: $viewModel.isSearchSheetPresented) {
                SearchLocationSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isSettingsPresented) {
                SettingsSheetView(viewModel: viewModel)
            }
            .overlay(alignment: .top) {
                if viewModel.isRefreshing {
                    ProgressView()
                        .padding(.top, 8)
                        .tint(.white)
                }
            }
        }
    }

    private var decorativeBackground: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 240, height: 240)
                .offset(x: -120, y: -340)

            Circle()
                .fill(Color.white.opacity(0.10))
                .frame(width: 200, height: 200)
                .offset(x: 150, y: -260)

            RoundedRectangle(cornerRadius: 64, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .frame(width: 320, height: 220)
                .rotationEffect(.degrees(22))
                .offset(x: 120, y: 420)
        }
        .allowsHitTesting(false)
    }

    private func inlineError(message: String) -> some View {
        Text(message)
            .font(.system(.footnote, design: .rounded, weight: .medium))
            .foregroundStyle(.white)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.32), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
