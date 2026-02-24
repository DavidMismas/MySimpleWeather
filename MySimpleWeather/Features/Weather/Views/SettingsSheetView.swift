import SwiftUI

struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Units") {
                    Picker("Temperature & wind", selection: unitBinding) {
                        ForEach(WeatherUnits.allCases) { unit in
                            Text(unit.displayName)
                                .tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Display") {
                    Toggle("Show minutely precipitation", isOn: minutelyBinding)
                }

                Section("Default Location") {
                    if let defaultLocation = viewModel.defaultLocation {
                        Text(defaultLocation.displayName)
                            .font(.system(.body, design: .rounded, weight: .semibold))

                        Button("Use Default Location Now") {
                            viewModel.useDefaultLocationNow()
                            dismiss()
                        }

                        Button("Clear Default Location", role: .destructive) {
                            viewModel.clearDefaultLocation()
                        }
                    } else {
                        Text("No default location saved.")
                            .foregroundStyle(.secondary)
                    }

                    Button("Save Current Shown Location as Default") {
                        viewModel.saveCurrentLocationAsDefault()
                    }
                    .disabled(!viewModel.hasWeather)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var unitBinding: Binding<WeatherUnits> {
        Binding(
            get: { viewModel.units },
            set: { viewModel.setUnits($0) }
        )
    }

    private var minutelyBinding: Binding<Bool> {
        Binding(
            get: { viewModel.showMinutely },
            set: { viewModel.setShowMinutely($0) }
        )
    }
}
