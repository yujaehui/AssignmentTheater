//
//  TheaterViewController.swift
//  AssignmentTheater
//
//  Created by Jaehui Yu on 1/17/24.
//

import UIKit
import MapKit
import CoreLocation

class TheaterViewController: UIViewController {
    
    @IBOutlet var theaterMapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var originalList = TheaterList().mapAnnotations
    var list = TheaterList().mapAnnotations {
        didSet {
            updateMapAnnotations()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateMapAnnotations()
        setNavigation()
        
        locationManager.delegate = self
        
        checkDeviceLocationAuthorization()
    }
    
    func updateMapAnnotations() {
        let coordinate = CLLocationCoordinate2D(latitude: 37.517749,
                                                longitude: 126.885450)
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: 15000,
                                        longitudinalMeters: 15000)
        theaterMapView.setRegion(region, animated: true)
        
        theaterMapView.removeAnnotations(theaterMapView.annotations) // 기존 핀 제거!!
        
        for theater in list {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: theater.latitude, longitude: theater.longitude)
            annotation.title = theater.location
            theaterMapView.addAnnotation(annotation)
        }
    }
    
    func setNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(rightBarButtonClicked))
    }
    
    @objc func rightBarButtonClicked() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let megaboxButton = UIAlertAction(title: "메가박스", style: .default) { action in
            self.list = self.originalList.filter { $0.type == action.title }
        }
        let lottecinemaButton = UIAlertAction(title: "롯데시네마", style: .default) { action in
            self.list = self.originalList.filter { $0.type == action.title }
        }
        let cgvButton = UIAlertAction(title: "CGV", style: .default) { action in
            self.list = self.originalList.filter { $0.type == action.title }
        }
        let allButton = UIAlertAction(title: "전체 보기", style: .default) { action in
            self.list = self.originalList
        }
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        
        sheet.addAction(megaboxButton)
        sheet.addAction(lottecinemaButton)
        sheet.addAction(cgvButton)
        sheet.addAction(allButton)
        sheet.addAction(cancelButton)
        
        present(sheet, animated: true)
    }
}

extension TheaterViewController {
    func checkDeviceLocationAuthorization() {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                let status: CLAuthorizationStatus = self.locationManager.authorizationStatus
                DispatchQueue.main.async {
                    self.checkCurrentLocationAuthorization(status: status)
                }
            } else {
                print("디바이스의 위치 서비스 비활성화 상태")
            }
        }
    }
    
    func checkCurrentLocationAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            showSettingAlert()
            
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        default: print("error")
        }
    }
    
    func showSettingAlert() {
        let alert = UIAlertController(title: "위치 정보를 사용할 수 없습니다.", message: "위치 서비스를 사용하려먼 '위치' 접근권한을 허용해야 합니다.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        let setting = UIAlertAction(title: "설정", style: .default) { _ in
            guard let settingURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingURL)
        }
        alert.addAction(cancel)
        alert.addAction(setting)
        present(alert, animated: true)
    }
}

extension TheaterViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        if let coordinate = locations.last?.coordinate {
            setRegionAndAnnotation(center: coordinate)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func setRegionAndAnnotation(center: CLLocationCoordinate2D) {
        let resion = MKCoordinateRegion(center: center, latitudinalMeters: 500, longitudinalMeters: 500)
        theaterMapView.setRegion(resion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkDeviceLocationAuthorization()
    }
}
