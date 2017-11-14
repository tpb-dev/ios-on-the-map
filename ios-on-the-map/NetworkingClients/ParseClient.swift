//
//  ParseClient.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/10/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import Foundation

class ParseClient : APIClient {
    
    override init() {
        super.init()
        self.headers = [
            "X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
            "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY",
            "Content-Type" : "application/json"
        ]
    }
    
    let getLocationURL = "https://parse.udacity.com/parse/classes/StudentLocation"
    let postLocationURL = "https://parse.udacity.com/parse/classes/StudentLocation"
    let oneStudentURL = "https://parse.udacity.com/parse/classes/StudentLocation"
    
    func getStudentLocations(responseHandler: @escaping (_ result: [ParseStudentModel]?, _ error: String?) -> Void) {
        
        let request = self.makeRequest(method: APIClient.Methods(rawValue: "GET")!, url: getLocationURL, requestBody: nil, params: ["limit": "100"])
        self.sendRequest(request: request){ (resp, err) -> Void in
            self.processStudents(response: resp!, responseHandler: responseHandler)
        }
    }
    
    func processStudents(response: [String: Any], responseHandler: @escaping (_ allStudents: [ParseStudentModel]?, _ error: String?) -> Void) {
        guard let respArray = response["results"] as? [[String : AnyObject]] else {
            print("Can't find [results] in response")
            return
        }
        
        var allStudents: [ParseStudentModel] = []
        
        for studentEntry in respArray {
            allStudents.append(ParseStudentModel(studentsArray: studentEntry))
        }
        
        allStudents.sort {
            return $0.updatedAt > $1.updatedAt
        }
        
        SharedMemory.instance.studentsArray = allStudents
        
        let parseClient = ParseClient()
        parseClient.checkPinExists()
        
        responseHandler(allStudents, nil)
        
    }
    
    func postPinLocation(responseHandler: @escaping (_ allStudents: [ParseStudentModel]?, _ error: String?) -> Void) {
        let requestBody: [String:Any] = ["uniqueKey" : SharedMemory.instance.key,
                                         "firstName" : SharedMemory.instance.firstName,
                                         "lastName" : SharedMemory.instance.lastName,
                                         "mapString" : SharedMemory.instance.personalLocation,
                                         "mediaURL" : SharedMemory.instance.mediaURL,
                                         "latitude" : SharedMemory.instance.personalLatitude,
                                         "longitude" : SharedMemory.instance.personalLongitude
        ]
        
        var method = "POST"
        var theURL = postLocationURL

        if SharedMemory.instance.alreadyExist == true {
            method = "PUT"
            theURL = postLocationURL + SharedMemory.instance.key
        }
        
                
        
        let request = self.makeRequest(method: APIClient.Methods(rawValue: method)!, url: theURL, requestBody: requestBody as AnyObject, params: [:])
        self.sendRequest(request: request, isUdacity: true){ (resp, err) -> Void in
            if resp != nil {
                let success = self.addSelfToUsers(resp: resp!)
            } else {
                responseHandler(nil, "Post fail for location")
            }
            
        }
    }
    
    func addSelfToUsers(resp: [String: Any?]) -> Bool {
        let dict: [String: Any] = [
            "firstName" : SharedMemory.instance.firstName,
            "lastName" : SharedMemory.instance.lastName,
            "longitude" : SharedMemory.instance.personalLongitude,
            "latitude" : SharedMemory.instance.personalLatitude,
            "mediaURL" : SharedMemory.instance.mediaURL,
            "mapString" : SharedMemory.instance.personalLocation,
            "objectId" : resp["objectId"]!,
            "uniqueKey" : SharedMemory.instance.key,
            "updatedAt" : resp["created_at"]!
        ]

        let me = ParseStudentModel(studentsArray: dict)
        
        SharedMemory.instance.studentsArray.append(me)
        
        return true
    }
    
    func checkPinExists() {
        
        let requestBody: [String:Any] = [:]
        let params: [String:Any] = ["where" : ["uniqueKey" : SharedMemory.instance.key]]
        
        let request = self.makeRequest(method: APIClient.Methods(rawValue: "GET")!, url: oneStudentURL, requestBody: requestBody as AnyObject, params: params)
        self.sendRequest(request: request, isUdacity: false){ (resp, err) -> Void in
            if resp != nil {
                let a = resp!["results"]! as! [String: Any]
                if a.count > 0 {
                    SharedMemory.instance.alreadyExist = true
                }
            }
        }
        
    }
}

