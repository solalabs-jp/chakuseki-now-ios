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
        .padding(.bottom)
    }
}

private struct LoginView: View {
    let onLogin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("ログイン")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppColors.labelPrimary)

                Text("仮ログイン画面")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.labelSecondary)
            }

            Button(action: onLogin) {
                Text("ホーム画面へ")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: 220)
                    .padding(.vertical, 12)
                    .background(AppColors.brandRed)
                    .foregroundColor(AppColors.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

#Preview {
    ContentView()
}
