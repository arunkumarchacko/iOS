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
    
    static func clearState() {
        AppDelegate.Instance.userId = nil
        AppDelegate.Instance.userInfo = nil
        OTMHttpClient.studentLocations = nil
    }
}
