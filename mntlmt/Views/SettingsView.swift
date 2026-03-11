import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Pass the user stats reference directly
    let userStats: UserStats
    
    // We bind to a local copy to allow immediate UI toggling,
    // then write back on dismiss or immediately
    @State private var localActiveCategories: Set<ProblemCategory> = []
    @State private var localSessionLength: Int = 20
    @State private var localGameMode: String = "Standard"
    @State private var localTimeAttackDuration: Int = 60
    @State private var localThemePreference: String = "System"
    @State private var localHapticsEnabled: Bool = true
    
    // Callback to tell GameEngine to reload config and potentially restart
    let onSettingsSaved: ([ProblemCategory], String) -> Void
    
    private func colorScheme(for preference: String) -> ColorScheme? {
        switch preference {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Game Mode")) {
                    Picker("Mode", selection: $localGameMode) {
                        Text("Standard").tag("Standard")
                        Text("Timed").tag("Timed")
                        Text("Zen").tag("Zen")
                    }
                    .pickerStyle(.segmented)
                    
                    if localGameMode == "Standard" {
                        Picker("Questions per Session", selection: $localSessionLength) {
                            Text("10").tag(10)
                            Text("20").tag(20)
                            Text("50").tag(50)
                            Text("Endless").tag(0)
                        }
                    } else if localGameMode == "Timed" {
                        Picker("Duration (Seconds)", selection: $localTimeAttackDuration) {
                            Text("30s").tag(30)
                            Text("60s").tag(60)
                            Text("120s").tag(120)
                        }
                    } else if localGameMode == "Zen" {
                        Text("Infinite practice with no constraints.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Categories")) {
                    ForEach(ProblemCategory.allCases, id: \.self) { category in
                        Toggle(category.rawValue, isOn: Binding(
                            get: { localActiveCategories.contains(category) },
                            set: { isSelected in
                                if isSelected {
                                    localActiveCategories.insert(category)
                                } else {
                                    if localActiveCategories.count > 1 {
                                        localActiveCategories.remove(category)
                                    }
                                }
                            }
                        ))
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Toggle("Haptic Feedback", isOn: $localHapticsEnabled)
                    
                    Picker("Theme", selection: $localThemePreference) {
                        Text("System").tag("System")
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: localThemePreference) { _, newValue in
                        userStats.themePreference = newValue
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveAndDismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(colorScheme(for: localThemePreference))
        .onAppear {
            localActiveCategories = Set(userStats.activeCategories)
            localSessionLength = userStats.sessionLength
            localGameMode = userStats.gameMode
            localTimeAttackDuration = userStats.timeAttackDuration
            localThemePreference = userStats.themePreference
            localHapticsEnabled = userStats.hapticsEnabled
        }
    }
    
    private func toggleCategory(_ category: ProblemCategory) {
        if localActiveCategories.contains(category) {
            // Prevent removing the last category
            if localActiveCategories.count > 1 {
                localActiveCategories.remove(category)
            }
        } else {
            localActiveCategories.insert(category)
        }
    }
    
    private func saveAndDismiss() {
        let newCategories = Array(localActiveCategories).sorted { $0.rawValue < $1.rawValue }
        userStats.activeCategories = newCategories
        userStats.sessionLength = localSessionLength
        userStats.gameMode = localGameMode
        userStats.timeAttackDuration = localTimeAttackDuration
        userStats.themePreference = localThemePreference
        userStats.hapticsEnabled = localHapticsEnabled
        
        onSettingsSaved(newCategories, localGameMode)
        dismiss()
    }
}
