import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn = false

    var body: some View {
        if isLoggedIn {
            MainTabView()
        } else {
            LoginView {
                isLoggedIn = true
            }
        }
    }
}

private struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var homeResetTrigger = 0

    private var selectedTabBinding: Binding<Int> {
        Binding {
            selectedTab
        } set: { newValue in
            if newValue == 0 {
                homeResetTrigger += 1
            }
            selectedTab = newValue
        }
    }
    
    var body: some View {
        TabView(selection: selectedTabBinding) {
            HomeView(resetTrigger: homeResetTrigger)
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("時間割", systemImage: "calendar")
                }
                .tag(1)

            GrowthView()
                .tabItem{
                    Label("マイページ", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
        }
        .padding(.horizontal)
       
    }
}

#Preview {
    ContentView()
}
