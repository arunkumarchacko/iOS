//
//  OTMHttpClient.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 26/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import Foundation

class OTMHttpClient {
    static var studentLocations: [StudentInformation]? = nil
    static var reloadRequired = false
    
    static func setStudentLocation(l: [StudentInformation]) {
        if studentLocations == nil {
            studentLocations = l
        }
    }
    
    static func invokeRequest(context: RequestContext, onSuccess: (AnyObject) -> (), onError: (String) -> ()) {
        print("invokeRequest - \(context.getRequest()?.URL)")
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(context.getRequest()!) { data, response, error in
            let error = context.checkForError(response, error: error)
            if let e = error {
                onError(e)
            }
            else {
                let parseResponse = context.parseData(data)
                if let e = parseResponse.0 {
                    onError(e)
                }
                else {
                    onSuccess(parseResponse.1!)
                }
            }
        }
        
        task.resume()
    }

//    static func getParseGetStudentLocationRequest() -> NSMutableURLRequest {
//        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
//        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
//        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
//        
//        return request
//    }
}