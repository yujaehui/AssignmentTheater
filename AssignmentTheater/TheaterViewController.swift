//
//  TheaterViewController.swift
//  AssignmentTheater
//
//  Created by Jaehui Yu on 1/17/24.
//

import UIKit
import MapKit

class TheaterViewController: UIViewController {
    
    @IBOutlet var theaterMapView: MKMapView!
    
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
    }
    
    func updateMapAnnotations() {
        let coordinate = CLLocationCoordinate2D(latitude: list[0].latitude,
                                                longitude: list[0].longitude)
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
