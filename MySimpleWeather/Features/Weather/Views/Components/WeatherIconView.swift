import SwiftUI

struct WeatherIconView: View {
    let iconCode: String
    var size: CGFloat = 52

    private var iconURL: URL? {
        URL(string: "https://openweathermap.org/payload/api/media/file/\(iconCode)@2x.png")
    }

    var body: some View {
        AsyncImage(url: iconURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
            case .empty:
                ProgressView()
                    .tint(.white)
            default:
                Image(systemName: "cloud.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .frame(width: size, height: size)
    }
}
