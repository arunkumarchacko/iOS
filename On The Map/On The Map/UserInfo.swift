//
//  UserInfo.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 28/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

internal struct UserInfo {
    let userId: String
    var firstName: String
    var lastName: String
    
    var loaded = false
    
    static func getUser(id: String, onError: (String) -> (), onSuccess: (UserInfo) -> ())  {
        OTMHttpClient.invokeRequest(UdacityUserDataContext(userId: id),
            onSuccess: {(data: AnyObject) -> () in onUserSuccess(data, onError: onError, onSuccess: onSuccess)}) { onError($0) }
    }
    
    static func onUserSuccess(data: AnyObject, onError: (String) -> (), onSuccess: (UserInfo) -> ()) {
        let parsedData = data as? [String: AnyObject]
        if let a = parsedData?["user"] as? [String: AnyObject] {
            let f = a["first_name"] as? String
            let l = a["last_name"] as? String
            let id = "\(a["key"])"
            print("d = \(f); \(l); \(id)")
            
            if let f=f, l=l {
                let userInfo = UserInfo(userId: id, firstName: f, lastName: l, loaded: true)
                onSuccess(userInfo)
                
                return
            }
            else {
                print("Unexpected response from Udacity - \(a)")
            }
        }
        
        onError("Failed to get user information from Udacity")
    }
}
