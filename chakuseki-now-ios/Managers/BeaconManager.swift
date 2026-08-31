import Foundation
import CoreLocation

/// 複数の UUID（＝各教員の `beaconId`）を同時に ranging する。
///
/// 初回検知だけでなく、コメント送信後の滞在継続監視でも使うため、
/// 検知後もスキャンを止めず `lastSeenAt` を更新し続ける。停止は `stop()` を明示的に呼ぶ。
final class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    /// 一度でも検知したか（初回の画面遷移トリガー用）。
    @Published var isBeaconDetected = false
    /// 直近で検知したビーコンの UUID。
    @Published var detectedUUID: UUID?
    /// 直近でビーコンを検知した時刻（圏内判定に使う）。
    @Published var lastSeenAt: Date?
    @Published var permissionDenied = false

    private var constraints: [CLBeaconIdentityConstraint] = []
    private var pendingUUIDs: [UUID] = []

    override init() {
        super.init()
        locationManager.delegate = self
    }

    /// 指定した UUID 群のビーコンスキャンを開始する（必要なら権限要求も行う）。
    func start(uuids: [UUID]) {
        pendingUUIDs = uuids
        isBeaconDetected = false
        detectedUUID = nil
        lastSeenAt = nil

        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            beginRanging()
        default:
            permissionDenied = true
        }
    }

    func stop() {
        for constraint in constraints {
            locationManager.stopRangingBeacons(satisfying: constraint)
        }
        constraints.removeAll()
    }

    private func beginRanging() {
        stop()
        guard !pendingUUIDs.isEmpty else { return }
        constraints = pendingUUIDs.map { CLBeaconIdentityConstraint(uuid: $0) }
        for constraint in constraints {
            locationManager.startRangingBeacons(satisfying: constraint)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            permissionDenied = false
            beginRanging()
        case .denied, .restricted:
            permissionDenied = true
        default:
            break
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didRange beacons: [CLBeacon],
        satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
        // 空配列は「このUUIDは今この瞬間 圏内に無い」の通知なので lastSeenAt は更新しない。
        guard !beacons.isEmpty else { return }
        let beacon = beacons.first(where: { $0.proximity != .unknown }) ?? beacons[0]

        DispatchQueue.main.async {
            self.detectedUUID = beacon.uuid
            self.lastSeenAt = Date()
            if !self.isBeaconDetected {
                self.isBeaconDetected = true
            }
        }
    }
}
