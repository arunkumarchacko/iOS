//
//  StudentLocation.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 26/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import Foundation
import MapKit

internal struct StudentInformation {
    let firstName: String
    let lastName: String
    let latitude: Double
    let longitude: Double
    let mediaUrl: String
    let mapString: String
    let udateTime: String
    
    static func ParseStudentLocations(data: [[String: AnyObject]]) -> [StudentInformation] {
        var result = [StudentInformation]()
        for sl in data {
            if let created = StudentInformation.create(sl) {
                result.append(created)
            }
        }
        
        result.sortInPlace() { $0.0.udateTime > $0.1.udateTime }
        return result
    }
    
    static func create(data: [String: AnyObject]) -> StudentInformation? {
        if let fn = getString(data, "firstName"), ln = getString(data, "lastName"), lat = data["latitude"] as? Double, long = data["longitude"] as? Double, mu = getString(data, "mediaURL"), ms = getString(data, "mapString"), uat = getString(data, "updatedAt") {
            return StudentInformation(firstName: fn, lastName: ln, latitude: lat, longitude: long, mediaUrl: mu, mapString: ms, udateTime: uat)
        }
        else {
            print("Parsing failed \(data)")
        }
        
        return nil
    }
    
    static func getString(data: [String: AnyObject], _ key: String) -> String? {
        return data[key] as? String
    }
    
    func getMapAnnotation() -> MKPointAnnotation {
        return Utils.getMapAnnotation(latitude, long: longitude, title: "\(firstName) \(lastName)", url: mediaUrl)
    }
}