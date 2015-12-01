//
//  OTMHttpClient.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 26/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import Foundation

class OTMHttpClient {
    static var studentLocations: [StudentInformation]? = nil { didSet { reloadRequired = false }}
    static var reloadRequired = false // Used to force refresh studentLocations from server.
    
    static func invokeRequest(context: RequestContext, onSuccess: (AnyObject) -> (), onError: (String) -> ()) {
        print("invokeRequest - \(context.getRequest()?.URL)")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(context.getRequest()!) { data, response, error in
            if let e = context.checkForError(response, error: error) {
                onError(e)
            }
            else if let d = data {
                let parseResponse = context.parseData(d)
                if let e = parseResponse.0 {
                    onError(e)
                }
                else {
                    onSuccess(parseResponse.1!)
                }
            }
            else {
                onError("Something unexpected happened. Please retry the operatio.")
            }
        }
        
        task.resume()
    }
}