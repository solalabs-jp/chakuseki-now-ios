import Foundation
import CoreLocation
import Combine

class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    
    @Published var isBeaconDetected = false
    @Published var detectedUUID: UUID?
    @Published var permissionDenied = false
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    func requestPermissionAndStart() {
        guard let locationManager = locationManager else { return }
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            startScanning()
        } else {
            permissionDenied = true
        }
    }
    
    func startScanning() {
        guard let uuid = UUID(uuidString: "01020304-0506-0708-090A-0B0C0D0E0F10") else { return }
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 256, minor: 1)
        locationManager?.startRangingBeacons(satisfying: constraint)
    }
    
    func stopScanning() {
        guard let uuid = UUID(uuidString: "01020304-0506-0708-090A-0B0C0D0E0F10") else { return }
        let constraint = CLBeaconIdentityConstraint(uuid: uuid, major: 256, minor: 1)
        locationManager?.stopRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            startScanning()
        } else if status == .denied || status == .restricted {
            permissionDenied = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            if !isBeaconDetected {
                DispatchQueue.main.async {
                    self.detectedUUID = beacon.uuid
                    self.isBeaconDetected = true
                }
                stopScanning()
            }
        }
    }
}
