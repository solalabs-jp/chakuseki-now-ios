import SwiftUI

struct ContentView: View {
    @State private var auth = AuthService.shared

    var body: some View {
        switch auth.status {
        case .initializing:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .signedOut:
            LoginView(auth: auth)

        case .signedIn:
            MainTabView()

        case .profileMissing(_, let email):
            ProfileMissingView(email: email) {
                auth.signOut()
            }
        }
    }
}

private struct ProfileMissingView: View {
    let email: String?
    let onSignOut: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 44))
                .foregroundColor(.secondary)
            Text("利用者情報が見つかりません")
                .font(.headline)
            Text("このアカウント\(email.map { "（\($0)）" } ?? "")に対応する利用者データが登録されていません。管理者にお問い合わせください。")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button("ログアウト", action: onSignOut)
                .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    Label("マイページ", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        .tint(AppColors.brandRed)
    }
}

#Preview {
    ContentView()
}
