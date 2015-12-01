//
//  RequestContext.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 27/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import Foundation
import UIKit

internal class RequestContext {
    func checkForError(response: NSURLResponse?, error: NSError?) -> String? {
        var msg = "Unable to connect to server. Make sure you are connected to the internet."
        if error == nil {
            if let r = response as? NSHTTPURLResponse {
                print("Status = \(r.statusCode);")
                if isSuccess(r) {
                    return nil
                }
                
                if isForbiddenResponseCode(r) {
                    msg = "Login failed. Make sure username and password is correct."
                }
                else if isServersideError(r) {
                    msg = "Something unexpected happened. Please retry after sometime."
                }
                else {
                    msg = "Encountered an unexpected error."
                }
            }
        }

        return msg
    }
    
    func parseData(data: NSData) -> (String?, AnyObject?) {
        print("successCallback")
        var newData: NSData? = nil
        let prefixToDiscard = getPrefixToDiscard()
        
        if prefixToDiscard != 0 && data.length >= prefixToDiscard {
            newData = data.subdataWithRange(NSMakeRange(prefixToDiscard, data.length - prefixToDiscard)) /* subset response data! */
        }
        
        let parsedResult: AnyObject!
        var errorMsg:String? = nil
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(newData == nil ? data : newData!, options: .AllowFragments)
        } catch {
            parsedResult = nil
            print("Could not parse the data as JSON: '\(data)'")
            errorMsg = "Encountered an unexepcted error. Please retry after some time."
        }
        
       // print("ParsedResult: \(parsedResult)")
        
        return (errorMsg, parsedResult)
    }
    
    func getRequest() -> NSMutableURLRequest? {
        return nil
    }
    
    func isForbiddenResponseCode(code: NSHTTPURLResponse) -> Bool {
        return code.statusCode == 403
    }
    
    func isServersideError(code: NSHTTPURLResponse) -> Bool {
        return code.statusCode >= 500
    }
    
    func isSuccess(code: NSHTTPURLResponse) -> Bool {
        return code.statusCode >= 200 && code.statusCode < 300
    }

    func getPrefixToDiscard() -> Int {
        return 0
    }
}

// MARK: Udacity Requests

internal class UdacityLoginContext: RequestContext {
    let userName: String
    let pwd: String
    
    init(userName: String, passwd: String) {
        self.userName = userName
        self.pwd = passwd
    }
    
    override func getRequest() -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(pwd)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        return request
    }
    
    override func getPrefixToDiscard() -> Int {
        return 5
    }
}

internal class UdacityFacebookLoginContext: RequestContext {
    let token: String
    
    init(accessToken: String) {
        token = accessToken
    }
    
    override func getRequest() -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(token);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        
        return request
    }
    
    override func getPrefixToDiscard() -> Int {
        return 5
    }
}

internal class UdacityUserDataContext: RequestContext {
    let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    override func getRequest() -> NSMutableURLRequest? {
        return NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userId)")!)
    }
    
    override func getPrefixToDiscard() -> Int {
        return 5
    }
}

internal class UdacityLogoutContext: RequestContext {
    override func getRequest() -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        if let c = sharedCookieStorage.cookies {
            for cookie in c {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        return request
    }
    
    override func getPrefixToDiscard() -> Int {
        return 5
    }
}

// MARK: Parse Requests

internal class ParseGetStudentLocationContext: RequestContext {
    override func getRequest() -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        return request
    }
}

internal class ParsePostStudentLocationContext: RequestContext {
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let url: String
    let location: String
    let userId: String
    
    init(firstName: String, lastName: String, location: String, url: String, lat: Double, long: Double, userId: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.location = location
        self.latitude = lat
        self.longitude = long
        self.url = url
        self.userId = userId
    }
    override func getRequest() -> NSMutableURLRequest? {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = "{\"uniqueKey\": \"\(userId)\", \"firstName\": \"\(firstName)\", \"lastName\": \"\(lastName)\",\"mapString\": \"\(location)\", \"mediaURL\": \"\(url)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}"
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        print("Body - \(body)")
        return request
    }
}
