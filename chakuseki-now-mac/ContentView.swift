import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab){
        
        HomeView()
            .tabItem {
                Label("ホーム",systemImage: "house")
            }
            .tag(0)
        
        HistoryView()
            .tabItem {
                Label("時間割",systemImage: "calendar")
            }
            .tag(1)
            
        GrowthView()
                .tabItem{
                    Label("成長",systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(2)
    }
        
    .padding()
    }
}

#Preview {
    ContentView()
}
