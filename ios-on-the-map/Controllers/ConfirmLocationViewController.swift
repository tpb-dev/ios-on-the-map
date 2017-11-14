//
//  ConfirmLocationViewController.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/11/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ConfirmLocationViewController: UIViewController, MKMapViewDelegate {
    
    let parseLogin = ParseClient()
    
    @IBOutlet var confViewController: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var finishButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Inside viewWillAppear for confirmlocationviewcontroller")
        finishButton.backgroundColor = UIColor(red: 234, green: 106, blue: 32)
        addPinToMap() 
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    func addPinToMap() {
        
        let annotation = MKPointAnnotation()
        let coordinates = CLLocationCoordinate2D(latitude: SharedMemory.instance.personalLatitude, longitude: SharedMemory.instance.personalLongitude)
        annotation.coordinate = coordinates
        annotation.title = SharedMemory.instance.personalLocation
       
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? MKPointAnnotation else { return nil }
        let identifier = "pin-marker"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
        
    @IBAction func finishAddLocation(_ sender: Any) {
        let parseClient = ParseClient()
        parseClient.postPinLocation() { (resp, err) -> Void in
            let mainQueue = DispatchQueue.main
            mainQueue.async(execute: {
    
                guard err == nil else {
                    self.showErrorAlert(message: err!, dismissButtonTitle: "OK")
                    return
                }
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
