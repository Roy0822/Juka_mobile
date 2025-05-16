import Foundation
import CoreLocation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.0427731, longitude: 121.5140326), // 公館區域
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    static let shared = LocationManager()
    
    override init() {
        super.init()
        
        // 在主線程初始化和設置locationManager
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager?.delegate = self
            self.locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager?.distanceFilter = 10 // 10米更新一次
            
            // 獲取當前授權狀態
            if #available(iOS 14.0, *) {
                self.authorizationStatus = self.locationManager?.authorizationStatus ?? .notDetermined
            } else {
                self.authorizationStatus = CLLocationManager.authorizationStatus()
            }
            
            // 如果已授權，則開始更新位置
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                self.locationManager?.startUpdatingLocation()
            }
        }
    }
    
    func requestLocationPermission() {
        DispatchQueue.main.async {
            print("請求位置權限...")
            self.locationManager?.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocation() {
        DispatchQueue.main.async {
            print("開始更新位置...")
            self.locationManager?.startUpdatingLocation()
        }
    }
    
    func stopUpdatingLocation() {
        DispatchQueue.main.async {
            self.locationManager?.stopUpdatingLocation()
        }
    }
    
    func getCurrentLocation() {
        DispatchQueue.main.async {
            if self.authorizationStatus == .authorizedWhenInUse || self.authorizationStatus == .authorizedAlways {
                print("已授權，獲取當前位置...")
                self.locationManager?.requestLocation() // 只請求一次位置更新
            } else {
                print("未授權，請求權限...")
                self.requestLocationPermission()
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            print("授權狀態變更：\(manager.authorizationStatus.rawValue)")
            
            // 更新授權狀態
            self.authorizationStatus = manager.authorizationStatus
            
            // 如果已授權，開始更新位置
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            if let location = locations.last {
                print("位置已更新: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                self.location = location
                
                // 更新地圖區域
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                )
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置更新失敗: \(error.localizedDescription)")
    }
} 