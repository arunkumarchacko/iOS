//
//  StudentLocationController.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 26/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationController: UIViewController {
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var location: CLPlacemark?
    
    @IBAction func onFindClicked(sender: AnyObject) {
        location = nil
        startActivityIndicator()
        CLGeocoder().geocodeAddressString(locationTextField.text!, completionHandler: onGeocodeCompletion)
//        let request = MKLocalSearchRequest()
//        request.naturalLanguageQuery = locationTextField.text!
//        
//        let search = MKLocalSearch(request: request)
//        search.startWithCompletionHandler() { a,b in self.onSearchCompleted(a, error: b) }
    }
    
    func onGeocodeCompletion(placeMarks: [CLPlacemark]?, error: NSError?) {
        stopActivityIndicator()
        
        if let e = error {
            print("Geocode failed \(e)")
        }
        else if placeMarks?.count > 0{
            location = placeMarks![0]
            let coordinate = location!.location?.coordinate
            var region = MKCoordinateRegion()
            region.center.latitude = (coordinate?.latitude)!
            region.center.longitude = (coordinate?.longitude)!
            region.span.latitudeDelta = 10;
            region.span.longitudeDelta = 10;
            
            let an = Utils.getMapAnnotation(coordinate!.latitude, long: coordinate!.longitude, title: location?.name == nil ? "" : location!.name! , url: "")
            
            Utils.dispatchMainUIThread() {self.mapView.removeAnnotations(self.mapView.annotations); self.mapView.addAnnotation(an); self.mapView.setRegion(region, animated: true)}
        }
        

//        print("onGeocodeCompletion \(a.country); \(a.locality); \(a.location); \(a.name);)")
    }
    
//    func onSearchCompleted(response: MKLocalSearchResponse?, error: NSError?) {
//        if let e = error {
//            print("Search operation failed. Details=\(e)")
//        }
//        
//        var a = [MKAnnotation]()
//        if let mi = response?.mapItems {
//            for m in mi {
//                let an = Utils.getMapAnnotation((m.placemark.location?.coordinate.latitude)!, long: (m.placemark.location?.coordinate.longitude)!, title: "", url: "")
//                a.append(an)
//                
//                print("Adding annotation \(m)")
//            }
//        }
//        
//        Utils.dispatchMainUIThread() { self.mapView.addAnnotations(a) }
//    }
    
    @IBAction func onPostClicked(sender: AnyObject) {
        print("onPostClicked")
        
        let url = urlTextField.text!
        let location = locationTextField.text!
        let firstName = AppDelegate.Instance.userInfo!.firstName
        let lastName = AppDelegate.Instance.userInfo!.lastName
        let id = AppDelegate.Instance.userInfo!.userId
        let lat = mapView.annotations[0].coordinate.latitude
        let long = mapView.annotations[0].coordinate.longitude

        startActivityIndicator()
        
        OTMHttpClient.reloadRequired = true
        OTMHttpClient.invokeRequest(ParsePostStudentLocationContext(firstName: firstName, lastName: lastName, location: location, url: url, lat: lat, long: long, userId: id), onSuccess: onPostSuccess, onError: onPostFailed)
    }
    
    @IBAction func onCancelClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onPostSuccess(data: AnyObject) {
        print("onPostSuccess - \(data)")
        stopActivityIndicator()
         dismissViewControllerAnimated(true, completion: nil)
    }
    
    func onPostFailed(error: String) {
        stopActivityIndicator()
        print("onPostFailed - \(error)")
    }
    
    func startActivityIndicator() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
}
