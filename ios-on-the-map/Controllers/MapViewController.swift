//
//  MapViewController.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/10/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let parseLogin = ParseClient()
    
    @IBOutlet var mapViewController: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Inside viewWillAppear for mapviewcontroller")
        refresh()
        for tabBarItem in tabBarController!.tabBar.items! {
            tabBarItem.title = ""
            tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
        }
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        refresh()
    }
    
    @IBAction func logout(_ sender: Any) {
        let udacityClient = UdacityClient()
        udacityClient.logout() { (resp, err) -> Void in
            if resp == nil {
                return
            }
        }
        let storyboard = self.storyboard
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginViewController!, animated: true, completion: nil)
           
    }
    
    func refresh () {
        mapView.removeAnnotations(mapView.annotations)
        parseLogin.getStudentLocations() { (response, error) -> Void in
            if error != nil {
                let mainQueue = DispatchQueue.main
                mainQueue.async(execute: {
                    
                    self.showErrorAlert(message: error!, dismissButtonTitle: "OK")
                    return
                })
            } else {
                print("Count = \(response?.count ?? 0)")
                self.addPinsToMap(students: response!)
            }
        }

    }
    
    func addPinsToMap(students: [ParseStudentModel]) {

        var annotationsArray = [MKPointAnnotation]()
        
        for student in students {
            let annotation = MKPointAnnotation()
            let coordinates = CLLocationCoordinate2D(latitude: student.latitude, longitude:student.longitude)
            annotation.coordinate = coordinates
            annotation.title = student.firstName + " " + student.lastName
            annotation.subtitle = student.mediaURL
            annotationsArray.append(annotation)
        }

        mapView.addAnnotations(annotationsArray)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("I got here at mapView click")

        let theURL : String = SharedMemory.instance.addHttps(url: view.annotation!.subtitle!)
        
        print(theURL)
        UIApplication.shared.open(URL(string: theURL)!, options: [:], completionHandler: nil)

    }
    
    
    
    @IBAction func openAddPinView(_ sender: Any) {
        let storyboard = self.storyboard
        let mapAddViewController = storyboard?.instantiateViewController(withIdentifier: "MapAddViewController")
        
        self.present(mapAddViewController!, animated: true, completion: nil)

    }    
    
}
