//
//  ParseStudentModel.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/10/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import Foundation

struct ParseStudentModel {
    
    
    var firstName: String
    var lastName: String
    var longitude: Double
    var latitude: Double
    var mediaURL: String
    var mapString: String
    var objectID: String
    var uniqKey: String
    var updatedAt: String

    init(studentsArray: [String : Any]) {
        firstName = studentsArray["firstName"] != nil ? studentsArray["firstName"] as! String! : "[No First Name]"
        lastName = studentsArray["lastName"]  != nil ? studentsArray["lastName"] as! String! : "[No Last Name]"
        longitude = studentsArray["longitude"] != nil ? studentsArray["longitude"] as! Double : 125.76
        latitude = studentsArray["latitude"] != nil ? studentsArray["latitude"] as! Double : 39.03
        mediaURL = studentsArray["mediaURL"] != nil ? studentsArray["mediaURL"] as! String! : "https://www.coursera.com"
        mapString = studentsArray["mapString"] != nil ? studentsArray["mapString"] as! String! : "[No Map String]"
        objectID = studentsArray["objectId"] != nil ? studentsArray["objectId"] as! String! : "911912"
        uniqKey = studentsArray["uniqueKey"] != nil ? studentsArray["uniqueKey"] as! String! : "9393939"
        updatedAt = studentsArray["updatedAt"] != nil ? studentsArray["updatedAt"] as! String! : "0"
    }
}
