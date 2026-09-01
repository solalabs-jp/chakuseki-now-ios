import SwiftUI
import UIKit

struct HomeSearchingContentView: View {
    /// 検知〜滞在監視まで通して使う共有 BeaconManager（`HomeView` が所有）。
    @ObservedObject var beaconManager: BeaconManager
    /// スキャン対象の教員ビーコン UUID を取得するクロージャ。
    let beaconUUIDsProvider: () async -> [UUID]
    let onStartConnection: (UUID) -> Void

    /// 教員ビーコンが1つも取得できなかった場合のフォールバック（従来の固定 UUID）。
    private let fallbackUUID = UUID(uuidString: "01020304-0506-0708-090A-0B0C0D0E0F10")

    var body: some View {
        Group {
            if beaconManager.permissionDenied {
                permissionDeniedView
            } else {
                searchingView
            }
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

    private var searchingView: some View {
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
    }

    /// 位置情報権限が拒否されている場合の案内。放置すると測距が始まらず無限にスピナーになるため、
    /// 理由と設定アプリへの導線を明示する。
    private var permissionDeniedView: some View {
        VStack(spacing: 16) {
            Text("位置情報の利用が許可されていません")
                .font(Font.custom("SF Pro", size: 16).weight(.semibold))
                .foregroundColor(AppColors.brownText)

            Text("出席チェックインにはビーコン検知のため位置情報が必要です。\n設定アプリで位置情報の利用を許可してください。")
                .font(Font.custom("SF Pro", size: 14).weight(.medium))
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.labelSecondary)

            Button {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text("設定を開く")
                    .font(Font.custom("SF Pro", size: 16).weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.brandRed)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeSearchingContentView(beaconManager: BeaconManager(), beaconUUIDsProvider: { [] }) { _ in }
}
