//
//  UdacityClient.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/9/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import Foundation

class UdacityClient: APIClient {

    override init() {
        super.init()
        self.headers = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
    
    let loginURL = "https://www.udacity.com/api/session"
    let publicUserDataURL = "https://www.udacity.com/api/users/"
    
    func login(username: String!, password: String!, handler: @escaping (_ result: [String: Any]?, _ error: String?) -> Void) {
        let innerBody : [String: String] = [
            "username" : username,
            "password" : password
        ]
        
        let requestBody : [String: Any] = [
        "udacity" : innerBody
        ]

        let request = self.makeRequest(method: APIClient.Methods(rawValue: "POST")!, url: loginURL, requestBody: requestBody as AnyObject, params: [:])
        self.sendRequest(request: request, isUdacity: true){ (resp, err) -> Void in
            if resp != nil {
                var success = self.storeUserKey(resp: resp!)
                if success == true {
                    self.getUserData(resp, err, handler: handler)
                } else {
                    handler(resp, err)
                }
                
            } else {
                handler(resp, err)
            }
        }
    }
    
    func logout(handler: @escaping (_ result: [String: Any]?, _ error: String?) -> Void) {
        
        let request = self.makeRequest(method: APIClient.Methods(rawValue: "DELETE")!, url: loginURL, requestBody: nil, params: [:])
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        self.sendRequest(request: request, isUdacity: true){ (resp, err) -> Void in
            handler(resp, err)
        }
    }
    
    func getUserData(_ result: [String: Any]?, _ error: String?, handler: @escaping (_ result: [String: Any]?, _ error: String?) -> Void) {
        let key = SharedMemory.instance.key
        
        let request = self.makeRequest(method: APIClient.Methods(rawValue: "GET")!, url: publicUserDataURL + key, requestBody: nil, params: [:])
        self.sendRequest(request: request, isUdacity: true){ (resp, err) -> Void in
            if resp != nil {
                _ = self.storeUserInfo(resp: resp!)
                handler(result, nil)
            } else {
                handler(nil, "Error getting student locations" )
            }
        }
    }
    
    func storeUserKey(resp: [String:Any?]) -> Bool {
        let a = resp["account"]! as! [String:AnyObject]
        let b = a["key"]
        SharedMemory.instance.key = b! as! String
        return true
    }
    
    func storeUserInfo(resp: [String:Any?]) -> Bool {
        guard let user = resp["user"] as? [String : AnyObject] else {
            print("user not in response")
            return false
        }
        
        guard let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
            print("first name and last name not there")
            return false
        }
        
        SharedMemory.instance.firstName = firstName
        SharedMemory.instance.lastName = lastName
        return true
    }
    

}
