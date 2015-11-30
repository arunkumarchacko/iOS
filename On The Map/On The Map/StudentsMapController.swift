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
    
    var studentLocations: [StudentInformation] = [StudentInformation]() { didSet { OTMHttpClient.setStudentLocation(studentLocations) }}
    override func viewDidLoad() {
        print("StudentsMapController - viewDidLoad")
        super.viewDidLoad()
        mapView.delegate = self

        if let l = OTMHttpClient.studentLocations {
            studentLocations = l
            reload()
        }
        else {
            OTMHttpClient.invokeRequest(ParseGetStudentLocationContext(), onSuccess: onStudentLocationLoaded, onError: onStudentLocationLoadError)
        }
    }

    func onStudentLocationLoaded(data: AnyObject) {
        let parsedData = data as? [String: AnyObject]
        if let a = parsedData?["results"] as? [[String: AnyObject]] {
            studentLocations = StudentInformation.ParseStudentLocations(a)
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
        studentLocations.forEach() { annotations.append($0.getMapAnnotation()) }
        
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
//            let app = UIApplication.sharedApplication()
//            if let toOpen = view.annotation?.subtitle! {
//                app.openURL(NSURL(string: toOpen)!)
//            }
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
    }
    
    @IBAction func onLogoutClicked(sender: UIBarButtonItem) {
        OTMHttpClient.invokeRequest(UdacityLogoutContext(), onSuccess: onLogoutSuccess, onError: onLogoutFailure)
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    func onLogoutSuccess(data: AnyObject) {
        print("Logout Success - \(data)")
        Utils.dispatchMainUIThread() { self.dismissViewControllerAnimated(true, completion: nil) }
        //Utils.dispatchMainUIThread() { self.navigationController?.popToRootViewControllerAnimated(true) }
    }
    
    func onLogoutFailure(error: String?) {
        print("Logout failure - \(error)")
        Utils.dispatchMainUIThread() { self.dismissViewControllerAnimated(true, completion: nil) }
    }
}
