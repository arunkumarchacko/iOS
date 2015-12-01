//
//  StudentsMapController.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 26/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class StudentsMapController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        print("StudentsMapController - viewDidLoad")
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    func refresh() {
        print("refresh")
        if OTMHttpClient.studentLocations == nil || OTMHttpClient.reloadRequired {
            OTMHttpClient.invokeRequest(ParseGetStudentLocationContext(), onSuccess: onStudentLocationLoaded, onError: onStudentLocationLoadError)
        }
        else {
            OTMHttpClient.studentLocations = OTMHttpClient.studentLocations!
            reload()
        }
    }

    func onStudentLocationLoaded(data: AnyObject) {
        let parsedData = data as? [String: AnyObject]
        if let a = parsedData?["results"] as? [[String: AnyObject]] {
            OTMHttpClient.studentLocations = StudentInformation.ParseStudentLocations(a)
            Utils.dispatchMainUIThread() { self.reload() }
        }
        else {
            let c = Utils.getAlertController("Operation failed", msg: "Encountered an unexpected error while processing student location data.")
            Utils.dispatchMainUIThread() { self.presentViewController(c, animated: true, completion: nil) }
        }
    }
    
    func onStudentLocationLoadError(error: String?) {
        let c = Utils.getAlertController("Operation failed", msg: error!)
        Utils.dispatchMainUIThread() { self.presentViewController(c, animated: true, completion: nil) }
    }

    func reload() {
        var annotations = [MKPointAnnotation]()
        OTMHttpClient.studentLocations?.forEach() { annotations.append($0.getMapAnnotation()) }
        
        mapView.addAnnotations(annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            Utils.openUrlInBroswer((view.annotation?.subtitle)!)
        }
    }
    
    @IBAction func onPinClicked(sender: UIBarButtonItem) {
        print("onPinClicked")
        if let _ = AppDelegate.Instance.userInfo {
            performSegueWithIdentifier("studentLocationDetailsSegue", sender: nil)
        }
        else {
            UserInfo.getUser(AppDelegate.Instance.userId!, onError: onUserLoadFailure, onSuccess: onLoadSuccess)
        }
    }
    
    func onLoadSuccess(userInfo: UserInfo) {
        print("onLoadSuccess - \(userInfo)")
        AppDelegate.Instance.userInfo = userInfo
        Utils.dispatchMainUIThread() { self.performSegueWithIdentifier("studentLocationDetailsSegue", sender: nil)}
    }
    
    func onUserLoadFailure(error: String) {
        print("onUserLoadFailure - \(error)")
        
        let c = Utils.getAlertController("Loading user information failed.", msg: error)
        Utils.dispatchMainUIThread() { self.presentViewController(c, animated: true, completion: nil) }
    }
    
    @IBAction func onLogoutClicked(sender: UIBarButtonItem) {
        if let _ = FBSDKAccessToken.currentAccessToken() {
            print("Logging out of facebook")
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            onLogoutSuccess("FB logout success")
        }
        else {
            print("Not logged in to Facebook")
            
            OTMHttpClient.invokeRequest(UdacityLogoutContext(), onSuccess: onLogoutSuccess, onError: onLogoutFailure)
        }
        
        Utils.clearState()
    }
    
    func onLogoutSuccess(data: AnyObject) {
        Utils.clearState()
        print("Logout Success - \(data)")
        Utils.dispatchMainUIThread() { self.dismissViewControllerAnimated(true, completion: nil) }
    }
    
    func onLogoutFailure(error: String?) {
        Utils.clearState()
        print("Logout failure - \(error)")
        Utils.dispatchMainUIThread() { self.dismissViewControllerAnimated(true, completion: nil) }
    }
}
