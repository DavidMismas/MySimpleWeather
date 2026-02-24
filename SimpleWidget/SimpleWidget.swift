import SwiftUI
import WidgetKit

private enum WidgetTheme {
    static let top = Color(red: 0.24, green: 0.17, blue: 0.46)
    static let middle = Color(red: 0.52, green: 0.22, blue: 0.47)
    static let bottom = Color(red: 0.67, green: 0.33, blue: 0.52)

    static let gradient = LinearGradient(
        colors: [top, middle, bottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let card = Color.white.opacity(0.16)
    static let cardBorder = Color.white.opacity(0.24)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.78)
}

private enum WidgetUnits: String {
    case metric
    case imperial

    var temperatureUnit: String {
        switch self {
        case .metric: return "C"
        case .imperial: return "F"
        }
    }

    var windUnit: String {
        switch self {
        case .metric: return "m/s"
        case .imperial: return "mph"
        }
    }

    static func from(raw: String) -> WidgetUnits {
        WidgetUnits(rawValue: raw) ?? .metric
    }
}

private enum WidgetFormat {
    static func temp(_ value: Double, units: WidgetUnits) -> String {
        "\(Int(value.rounded()))°\(units.temperatureUnit)"
    }

    static func wind(_ value: Double, units: WidgetUnits) -> String {
        String(format: "%.1f %@", value, units.windUnit)
    }

    static func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    static func precipitation(_ value: Double?) -> String {
        guard let value else { return "--" }
        return String(format: "%.1f mm/h", value)
    }

    static func dayLabel(unix: Int, timezoneOffset: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unix + timezoneOffset))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }

    static func updated(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    static func symbol(from iconCode: String) -> String {
        if iconCode.hasPrefix("01") {
            return iconCode.hasSuffix("n") ? "moon.stars.fill" : "sun.max.fill"
        }
        if iconCode.hasPrefix("02") {
            return iconCode.hasSuffix("n") ? "cloud.moon.fill" : "cloud.sun.fill"
        }
        if iconCode.hasPrefix("03") || iconCode.hasPrefix("04") {
            return "cloud.fill"
        }
        if iconCode.hasPrefix("09") {
            return "cloud.drizzle.fill"
        }
        if iconCode.hasPrefix("10") {
            return "cloud.rain.fill"
        }
        if iconCode.hasPrefix("11") {
            return "cloud.bolt.rain.fill"
        }
        if iconCode.hasPrefix("13") {
            return "cloud.snow.fill"
        }
        if iconCode.hasPrefix("50") {
            return "cloud.fog.fill"
        }
        return "cloud.fill"
    }
}

struct Provider: TimelineProvider {
    private let reader = WidgetSnapshotReader()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: .now, snapshot: .preview)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let snapshot = reader.load() ?? .preview
        completion(SimpleEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: .now, snapshot: reader.load())
        let refresh = Calendar.current.date(byAdding: .minute, value: 20, to: .now) ?? .now.addingTimeInterval(1200)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetWeatherSnapshot?
}

struct SimpleWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: SimpleEntry

    private var units: WidgetUnits {
        WidgetUnits.from(raw: entry.snapshot?.unitsRaw ?? "metric")
    }

    var body: some View {
        if let snapshot = entry.snapshot {
            switch family {
            case .systemSmall:
                smallView(snapshot)
            case .systemMedium:
                mediumView(snapshot)
            default:
                largeView(snapshot)
            }
        } else {
            unavailableView
        }
    }

    private var unavailableView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Open Aura")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(WidgetTheme.primaryText)
            Text("Widget updates after the app loads weather.")
                .font(.system(.footnote, design: .rounded))
                .foregroundStyle(WidgetTheme.secondaryText)
        }
        .padding(14)
    }

    private func smallView(_ snapshot: WidgetWeatherSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(snapshot.locationName)
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundStyle(WidgetTheme.secondaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .center, spacing: 8) {
                Image(systemName: WidgetFormat.symbol(from: snapshot.conditionIcon))
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text(WidgetFormat.temp(snapshot.currentTemp, units: units))
                        .font(.system(size: 27, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetTheme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .layoutPriority(1)
                    Text(snapshot.conditionDescription.capitalized)
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(WidgetTheme.secondaryText)
                        .lineLimit(1)
                }
            }

            Text("Feels \(WidgetFormat.temp(snapshot.feelsLike, units: units))")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(WidgetTheme.secondaryText)
        }
        .padding(14)
    }

    private func mediumView(_ snapshot: WidgetWeatherSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(snapshot.locationName)
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundStyle(WidgetTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.bottom, -2)

            HStack(alignment: .center, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: WidgetFormat.symbol(from: snapshot.conditionIcon))
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(WidgetFormat.temp(snapshot.currentTemp, units: units))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetTheme.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 5) {
                    Text("Humidity \(snapshot.humidity)%")
                    Text("Wind \(WidgetFormat.wind(snapshot.windSpeed, units: units))")
                }
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundStyle(WidgetTheme.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            }

            HStack(spacing: 7) {
                ForEach(Array(snapshot.daily.prefix(5))) { day in
                    mediumDailyColumn(day: day, timezoneOffset: snapshot.timezoneOffset)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 9)
    }

    private func largeView(_ snapshot: WidgetWeatherSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(snapshot.locationName)
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundStyle(WidgetTheme.primaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Updated \(WidgetFormat.updated(snapshot.updatedAt))")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(WidgetTheme.secondaryText)
                }

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: WidgetFormat.symbol(from: snapshot.conditionIcon))
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(WidgetFormat.temp(snapshot.currentTemp, units: units))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(WidgetTheme.primaryText)
                }
            }

            precipitationBlock(snapshot)

            VStack(spacing: 6) {
                ForEach(Array(snapshot.daily.prefix(6))) { day in
                    HStack(spacing: 8) {
                        Text(WidgetFormat.dayLabel(unix: day.dt, timezoneOffset: snapshot.timezoneOffset))
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundStyle(WidgetTheme.secondaryText)
                            .frame(width: 32, alignment: .leading)

                        Image(systemName: WidgetFormat.symbol(from: day.icon))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)

                        Text("\(Int(day.maxTemp.rounded()))° / \(Int(day.minTemp.rounded()))°")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(WidgetTheme.primaryText)

                        Spacer(minLength: 0)

                        Text("Rain \(WidgetFormat.percent(day.pop))")
                            .font(.system(.caption2, design: .rounded, weight: .medium))
                            .foregroundStyle(WidgetTheme.secondaryText)
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(10)
            .background(WidgetTheme.card, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(WidgetTheme.cardBorder, lineWidth: 1)
            )
        }
        .padding(12)
    }

    private func precipitationBlock(_ snapshot: WidgetWeatherSnapshot) -> some View {
        HStack(spacing: 8) {
            statPill(title: "Next 1h", value: WidgetFormat.precipitation(snapshot.nextHourPrecipitationTotal))
            statPill(title: "Rain", value: WidgetFormat.precipitation(snapshot.currentRainOneHour))
            statPill(title: "Snow", value: WidgetFormat.precipitation(snapshot.currentSnowOneHour))
        }
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(WidgetTheme.secondaryText)
            Text(value)
                .font(.system(.caption, design: .rounded, weight: .bold))
                .foregroundStyle(WidgetTheme.primaryText)
                .lineLimit(1)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WidgetTheme.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func mediumDailyColumn(day: WidgetDailyForecastSnapshot, timezoneOffset: Int) -> some View {
        VStack(spacing: 2) {
            Text(WidgetFormat.dayLabel(unix: day.dt, timezoneOffset: timezoneOffset))
                .font(.system(.caption2, design: .rounded, weight: .semibold))
                .foregroundStyle(WidgetTheme.secondaryText)

            Image(systemName: WidgetFormat.symbol(from: day.icon))
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)

            Text("\(Int(day.maxTemp.rounded()))°")
                .font(.system(.caption2, design: .rounded, weight: .bold))
                .foregroundStyle(WidgetTheme.primaryText)

            Text("\(Int(day.minTemp.rounded()))°")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(WidgetTheme.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .background(WidgetTheme.card, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(WidgetTheme.cardBorder, lineWidth: 1)
        )
    }
}

struct SimpleWidget: Widget {
    let kind: String = "SimpleWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                SimpleWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget) {
                        WidgetTheme.gradient
                    }
            } else {
                SimpleWidgetEntryView(entry: entry)
                    .padding()
                    .background(WidgetTheme.gradient)
            }
        }
        .configurationDisplayName("Aura Weather")
        .description("Current weather in small, with daily and precipitation in larger sizes.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    SimpleWidget()
} timeline: {
    SimpleEntry(date: .now, snapshot: .preview)
}

#Preview(as: .systemMedium) {
    SimpleWidget()
} timeline: {
    SimpleEntry(date: .now, snapshot: .preview)
}

#Preview(as: .systemLarge) {
    SimpleWidget()
} timeline: {
    SimpleEntry(date: .now, snapshot: .preview)
}
