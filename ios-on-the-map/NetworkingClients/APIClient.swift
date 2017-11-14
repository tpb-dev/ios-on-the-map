//
//  APIClient.swift
//  ios-on-the-map
//
//  Created by Randall Tom on 11/9/17.
//  Copyright © 2017 Randall Tom. All rights reserved.
//

import Foundation

class APIClient {
    
    enum Methods : String {
        case POST
        case GET
        case DELETE
        case PUT
    }
    
    var headers: [String: String] = [String: String]()
    
    var theSession: URLSession = URLSession.shared
    
    func makeRequest(method: Methods = .GET, url: String, requestBody: AnyObject? = nil, params: [String: Any] = [String: AnyObject]()) -> NSMutableURLRequest {
        let theURL = url + "?" + encodeParams(params: params)
        let request = NSMutableURLRequest(url: NSURL(string: theURL)! as URL)
        request.httpMethod = method.rawValue
        
        for (headerKey, values) in headers {
            request.addValue(values, forHTTPHeaderField: headerKey)
        }
        
        if requestBody != nil {
            request.httpBody = try! JSONSerialization.data(withJSONObject: requestBody!, options: .prettyPrinted)
        }
        
        return request
    }
    
    func sendRequest(request: NSMutableURLRequest, isUdacity: Bool = false, responseHandler: @escaping (_ result: [String: Any]?, _ error: String?) -> Void ) {
       
        let requesttask = theSession.dataTask(with: request as URLRequest) { (data, response, error) in
        
            print("Got to beginning of task")
            
            guard error == nil else {
                responseHandler(nil, "There was a connection error")
                return
            }

            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode, httpStatusCode != 403 else {
                responseHandler(nil, "Login credentials incorrect!!!")
                return
            }
            
            guard  httpStatusCode >= 200 && httpStatusCode <= 299 else {
                responseHandler(nil, "Some type of connection error")
                return
            }

            guard data != nil else {
                responseHandler(nil, "Another connection error!")
                return
            }
            
            print("Got here after http errors")
            
            var parsedData = data
            
            if isUdacity == true {
                let range = Range(5..<data!.count)
                let newData = data?.subdata(in: range)
                parsedData = newData
            }
            
            let (returnJSON, err) = self.receiveResponse(data: parsedData!)
            
            print("After receiving response")
            
            if err != true {
                responseHandler(returnJSON, nil)
            } else {
                responseHandler(nil, "Error performing JSON deserialization")
                return
            }
        }
        
        requesttask.resume()
    }
    
    func receiveResponse(data: Data) -> ([String:Any?], Bool){
        
        let returnJSON: [String: Any?]!

        do {
            returnJSON = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        } catch {
            print ("Catch block of JSON Serialization")
            return ([:], true)
        }
        
        return (returnJSON, false)
    }
    
    func encodeParams(params: [String: Any]) -> String {
        var str : String = ""
        for (key, value) in params {
            str += String(key) + "=" + String(describing: value) + "&"
        }
        if str.count  > 0 {
            str = String(str.dropLast())
        }
        return str.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
}
