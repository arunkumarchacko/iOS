//
//  Utils.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 27/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import Foundation
import MapKit

internal class Utils {
    static func getMapAnnotation(lat: Double, long: Double, title: String, url: String) -> MKPointAnnotation{
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
        annotation.title = title
        annotation.subtitle = url
        
        return annotation
    }
    
    static func dispatchMainUIThread(callBack: () -> ()) {
        dispatch_async(dispatch_get_main_queue()) { callBack() }
    }
    
//    static func logoutUdacity(controller: UIViewController) {
//        
//        print("logging out of udacity")
//        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
//        request.HTTPMethod = "DELETE"
//        var xsrfCookie: NSHTTPCookie? = nil
//        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
//        
//        if let c = sharedCookieStorage.cookies {
//            for cookie in c {
//                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
//            }
//        }
//        
//        if let xsrfCookie = xsrfCookie {
//            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
//        }
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request) { data, response, error in
//            if error != nil { // Handle error…
//                return
//            }
//            
//            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
//            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
//            
//            Utils.dispatchMainUIThread() { controller.dismissViewControllerAnimated(true, completion: nil) }
//        }
//        
//        task.resume()
//    }
        
    static func openUrlInBroswer(url: String?) {
        print("Opening url \(url)")
        let app = UIApplication.sharedApplication()
        
        if let u = url {
            app.openURL(NSURL(string: u)!)
        }
    }
    
    static func getAlertController(title: String, msg: String) -> UIAlertController {
        let c = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        c.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        return c
    }
}
