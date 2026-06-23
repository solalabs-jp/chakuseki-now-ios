import SwiftUI

struct HomeSearchingContentView: View {
    let onStartConnection: (UUID) -> Void
    @StateObject private var beaconManager = BeaconManager()

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
        .onAppear {
            beaconManager.requestPermissionAndStart()
        }
        .onDisappear {
            beaconManager.stopScanning()
        }
        .onChange(of: beaconManager.isBeaconDetected) { _, isDetected in
            if isDetected, let uuid = beaconManager.detectedUUID {
                onStartConnection(uuid)
            }
        }
    }
}

#Preview {
    HomeSearchingContentView { _ in }
}
