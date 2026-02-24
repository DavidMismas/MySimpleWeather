# MySimpleWeather

SwiftUI iOS weather app (iOS 17+) using OpenWeather One Call API 3.0 for weather data, plus OpenWeather Geocoding for city search and reverse lookup.

## Setup
1. Open `/Users/david/Documents/CODE/MySimpleWeather/MySimpleWeather.xcodeproj` in Xcode.
2. Copy `/Users/david/Documents/CODE/MySimpleWeather/OpenWeatherSecrets.sample.swift` to `/Users/david/Documents/CODE/MySimpleWeather/MySimpleWeather/OpenWeatherSecrets.swift`.
3. Paste your OpenWeather API key:
   - `enum OpenWeatherSecrets { static let apiKey = "PUT_KEY_HERE" }`
4. Build and run on iOS 17+ simulator/device.

## Permissions
- `NSLocationWhenInUseUsageDescription` is required and configured for first-launch location weather.
- App + widget use App Group: `group.com.david.MySimpleWeather.shared`.

## OpenWeather Endpoints (Official)
- One Call 3.0:
  - `https://api.openweathermap.org/data/3.0/onecall?lat={lat}&lon={lon}&appid={API key}`
- Direct geocoding (city search):
  - `https://api.openweathermap.org/geo/1.0/direct?q={city name},{state code},{country code}&limit={limit}&appid={API key}`
- Reverse geocoding:
  - `https://api.openweathermap.org/geo/1.0/reverse?lat={lat}&lon={lon}&limit={limit}&appid={API key}`

## Query options used
- `units=metric` or `units=imperial`
- `lang={language code}` (for localized weather description)

## Icon URL
- `https://openweathermap.org/payload/api/media/file/{icon}@2x.png`

## Notes
- The app uses only One Call 3.0 weather fields: current, minutely, hourly, daily, alerts.
- Air Pollution API is intentionally not included.
- Search requests are debounced.
- Search uses geocoding `limit=5` (OpenWeather max).
- Weather refreshes are throttled per location (10-minute minimum) to align with OpenWeather best-practice guidance.
- The app caches the last successful payload in memory and `UserDefaults` for quick startup.
- Minutely precipitation is shown in `mm/h` per One Call field docs.
- Settings can save the currently shown location as a default location and load it quickly later.
- Widget reads weather snapshot from the app via App Group shared storage (no direct OpenWeather API calls from widget).
- Add the same App Group capability to both targets in Xcode Signing & Capabilities if your provisioning profile does not already include it.

## Security
- Keep `OpenWeatherSecrets.swift` out of git (`.gitignore` includes it by default).
