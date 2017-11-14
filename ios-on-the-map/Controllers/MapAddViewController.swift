//
//  MapAddViewController.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/11/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class MapAddViewController: UIViewController {
    

    @IBOutlet var mapAddView: UIView!
    
    @IBOutlet weak var mapAddLocationTextField: UITextField!
    @IBOutlet weak var mapAddWebsiteTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    lazy var geocoder = CLGeocoder()
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Inside viewWillAppear for MapAddViewController")
        findLocationButton.titleLabel?.textAlignment = NSTextAlignment.center
        activityIndicatorView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func findLocationClicked(_ sender: Any) {
        //TODO
        
        guard let address = mapAddLocationTextField.text else { return }
        guard let mediaURL = mapAddWebsiteTextField.text else { return }
        
         SharedMemory.instance.personalLocation = address
         SharedMemory.instance.mediaURL = mediaURL
        
        print("find location button clicked")
        self.geocode(address: address, mediaURL: mediaURL)
    }
    
    func geocode(address: String!, mediaURL: String!) {
        
        findLocationButton.isHidden = false
        activityIndicatorView.startAnimating()
        
        self.geocoder.geocodeAddressString(address) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
        
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {

        findLocationButton.isHidden = true
        activityIndicatorView.stopAnimating()
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            let mainQueue = DispatchQueue.main
            mainQueue.async(execute: {
                
                self.showErrorAlert(message: "Unable to Forward Geocode Address", dismissButtonTitle: "OK" )
                return
            })
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                SharedMemory.instance.personalLatitude = coordinate.latitude
                SharedMemory.instance.personalLongitude = coordinate.longitude
                
                goToConfirmView()
            } else {
                print("Error with location lookup for coordinates")
            }
        }
        
    }
    
    private func goToConfirmView() {
        let storyboard = self.storyboard
        let confirmViewController = storyboard?.instantiateViewController(withIdentifier: "ConfirmLocationViewController")
        
        self.present(confirmViewController!, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
