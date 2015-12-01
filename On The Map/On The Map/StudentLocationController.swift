//
//  StudentLocationController.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 26/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit
import MapKit

class StudentLocationController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var findOnMapButton: UIButton!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    
    var location: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlTextField.delegate = self
        locationTextField.delegate = self
    }
    
    @IBAction func onTextChanged(sender: AnyObject) {
        findOnMapButton.enabled = locationTextField.text?.characters.count != 0
        enableSubmitButton()
    }
    
    @IBAction func onFindClicked(sender: AnyObject) {
        location = nil
        startActivityIndicator()
        CLGeocoder().geocodeAddressString(locationTextField.text!, completionHandler: onGeocodeCompletion)
    }
    
    func onGeocodeCompletion(placeMarks: [CLPlacemark]?, error: NSError?) {
        stopActivityIndicator()
        
        if let _ = error {
            onPostFailed("Geocoding failed.")
        }
        else if placeMarks?.count > 0{
            location = placeMarks![0]
            let coordinate = location!.location?.coordinate
            
            let an = Utils.getMapAnnotation(coordinate!.latitude, long: coordinate!.longitude, title: location?.name == nil ? "" : location!.name! , url: "")
            
            Utils.dispatchMainUIThread() { self.updateMapView(an) }
        }
    }
    
    @IBAction func onPostClicked(sender: AnyObject) {
        print("onPostClicked")
        
        let url = urlTextField.text!
        let locationName = locationTextField.text!
        let firstName = AppDelegate.Instance.userInfo!.firstName
        let lastName = AppDelegate.Instance.userInfo!.lastName
        let id = AppDelegate.Instance.userInfo!.userId
        let lat = location?.location?.coordinate.latitude
        let long = location?.location?.coordinate.longitude

        startActivityIndicator()
        
        OTMHttpClient.reloadRequired = true
        let context = ParsePostStudentLocationContext(firstName: firstName, lastName: lastName, location: locationName, url: url, lat: lat!, long: long!, userId: id)
        OTMHttpClient.invokeRequest(context, onSuccess: onPostSuccess, onError: onPostFailed)
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
        
        let c = Utils.getAlertController("Operation failed", msg: error)
        
        Utils.dispatchMainUIThread() { self.presentViewController(c, animated: true, completion: nil) }
    }
    
    func startActivityIndicator() {
        view.alpha = 0.7
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        view.alpha = 1
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func updateMapView(an: MKPointAnnotation) {
        let coordinate = location!.location?.coordinate
        var region = MKCoordinateRegion()
        region.center.latitude = (coordinate?.latitude)!
        region.center.longitude = (coordinate?.longitude)!
        region.span.latitudeDelta = 10;
        region.span.longitudeDelta = 10;
        
        mapView.removeAnnotations( mapView.annotations );
        mapView.addAnnotation(an);
        mapView.setRegion(region, animated: true)
        
        enableSubmitButton()
    }
    
    func enableSubmitButton() {
        if let _ = location {
            submitButton.enabled = urlTextField.text?.characters.count > 0
            return
        }

        submitButton.enabled = false
    }
}
