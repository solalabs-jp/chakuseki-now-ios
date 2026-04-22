//
//  chakuseki_now_macApp.swift
//  chakuseki-now-mac
//
//  Created by 鈴木拓也 on 2026/04/22.
//

import SwiftUI
import SwiftData

@main
struct chakuseki_now_macApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
