//
//  SharedMemory.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/10/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class SharedMemory {
    
    var studentsArray: [ParseStudentModel] = [ParseStudentModel]()

    static let instance = SharedMemory()
    
    var personalLatitude: Double = 40.33
    var personalLongitude: Double = 127.51
    var personalLocation = "North Korea"
    var key: String
    var lastName = "Kim"
    var firstName = "Jong-Un"
    var mediaURL = "https://www.naver.com"
    var alreadyExist: Bool = false
    
    private init() {
        personalLatitude = 40.33
        personalLongitude = 127.51
        personalLocation = "North Korea"
        key = "03243253423423"
        lastName = "Kim"
        firstName = "Jong-Un"
        mediaURL = "https://www.naver.com"
        studentsArray = [ParseStudentModel]()
        alreadyExist = false
    }
    
    func addHttps(url: String!) -> String! {
        if url.lowercased().range(of:"https://") == nil && url.lowercased().range(of:"http://") == nil {
            return "https://" + url
        } else {
            return url
        }
    }
}
