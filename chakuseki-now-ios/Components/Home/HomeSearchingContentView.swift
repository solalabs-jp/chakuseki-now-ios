import SwiftUI

struct HomeSearchingContentView: View {
    /// 検知〜滞在監視まで通して使う共有 BeaconManager（`HomeView` が所有）。
    @ObservedObject var beaconManager: BeaconManager
    /// スキャン対象の教員ビーコン UUID を取得するクロージャ。
    let beaconUUIDsProvider: () async -> [UUID]
    let onStartConnection: (UUID) -> Void

    /// 教員ビーコンが1つも取得できなかった場合のフォールバック（従来の固定 UUID）。
    private let fallbackUUID = UUID(uuidString: "01020304-0506-0708-090A-0B0C0D0E0F10")

    var body: some View {
        VStack(spacing: 15) {
            MainButton(title: "接続を開始する")

            Text("デバイスを机の上に置き、\nしばらくお待ちください。")
                .font(
                    Font.custom("SF Pro", size: 16)
                        .weight(.medium)
                )
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.brownText)
                .frame(width: 244.12, height: 42, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .task {
            var uuids = await beaconUUIDsProvider()
            if uuids.isEmpty, let fallbackUUID {
                uuids = [fallbackUUID]
            }
            beaconManager.start(uuids: uuids)
        }
        .onChange(of: beaconManager.isBeaconDetected) { _, isDetected in
            if isDetected, let uuid = beaconManager.detectedUUID {
                onStartConnection(uuid)
            }
        }
    }
}

#Preview {
    HomeSearchingContentView(beaconManager: BeaconManager(), beaconUUIDsProvider: { [] }) { _ in }
}
