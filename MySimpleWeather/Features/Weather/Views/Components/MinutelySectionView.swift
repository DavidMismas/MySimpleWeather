import Charts
import SwiftUI

struct MinutelySectionView: View {
    let items: [MinutelyWeather]
    let units: WeatherUnits

    private var chartPoints: [(minute: Int, precipitation: Double)] {
        Array(items.prefix(30).enumerated()).map { index, item in
            (minute: index, precipitation: item.precipitation)
        }
    }

    var body: some View {
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Minutely Precipitation")
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)

                Chart(chartPoints, id: \.minute) { point in
                    BarMark(
                        x: .value("Minute", point.minute),
                        y: .value("Precipitation", point.precipitation)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white.opacity(0.9), Color.white.opacity(0.55)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks(values: [0, 10, 20, 30]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                            .foregroundStyle(.white.opacity(0.2))
                        AxisValueLabel {
                            if let minute = value.as(Int.self) {
                                Text("+\(minute)m")
                            }
                        }
                    }
                }
                .chartYAxisLabel(position: .leading) {
                    Text(units.precipitationUnit)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                .frame(height: 170)

                let next10m = items.prefix(10).reduce(0) { $0 + $1.precipitation }
                Text("Next 10 minutes total: \(WeatherFormatters.precipitation(next10m, units: units))")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(AppTheme.secondaryText)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(items.prefix(6).enumerated()), id: \.offset) { index, minute in
                            Text("+\(index)m: \(WeatherFormatters.precipitation(minute.precipitation, units: units))")
                                .font(.system(.caption2, design: .rounded, weight: .semibold))
                                .foregroundStyle(AppTheme.secondaryText)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 9)
                                .background(Color.white.opacity(0.14), in: Capsule())
                        }
                    }
                }
            }
            .glassCard()
        }
    }
}
