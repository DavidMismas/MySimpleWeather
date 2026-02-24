import SwiftUI

struct SearchLocationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(AppTheme.secondaryText)

                    TextField("Search city, state, country", text: $viewModel.searchText)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()

                    if !viewModel.searchText.isEmpty {
                        Button {
                            viewModel.updateSearch(text: "")
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(AppTheme.secondaryText)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.16), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

                if viewModel.isSearching {
                    ProgressView("Searching…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 4)
                }

                if let searchErrorMessage = viewModel.searchErrorMessage {
                    Text(searchErrorMessage)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.red.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty && !viewModel.isSearching {
                    EmptyStateView(
                        title: "No Results",
                        message: "Try adding country code (for example: London, GB).",
                        buttonTitle: "Use My Location"
                    ) {
                        viewModel.useMyLocation()
                        dismiss()
                    }
                } else {
                    List(viewModel.searchResults) { result in
                        Button {
                            viewModel.selectSearchResult(result)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(result.name)
                                    .font(.system(.body, design: .rounded, weight: .semibold))
                                Text(result.displayName)
                                    .font(.system(.footnote, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("My Location") {
                        viewModel.useMyLocation()
                        dismiss()
                    }
                }
            }
            .onChange(of: viewModel.searchText) { _, newValue in
                viewModel.updateSearch(text: newValue)
            }
        }
        .presentationDetents([.medium, .large])
    }
}
