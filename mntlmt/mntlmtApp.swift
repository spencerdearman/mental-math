//
//  mntlmtApp.swift
//  mntlmt
//
//  Created by Spencer Dearman on 3/10/26.
//

import SwiftUI
import SwiftData

@main
struct mntlmtApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: UserStats.self)
    }
}
