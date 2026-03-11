//
//  ContentView.swift
//  mntlmt
//
//  Created by Spencer Dearman on 3/10/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var allStats: [UserStats]
    
    var body: some View {
        GameView()
            .preferredColorScheme(colorScheme(for: allStats.first?.themePreference ?? "System"))
    }
    
    private func colorScheme(for preference: String) -> ColorScheme? {
        switch preference {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
}

#Preview {
    ContentView()
}
