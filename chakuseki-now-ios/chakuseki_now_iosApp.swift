import SwiftUI
import FirebaseCore

@main
struct chakuseki_now_iosApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
