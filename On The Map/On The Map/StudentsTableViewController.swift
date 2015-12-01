//
//  StudentsTableViewController.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 26/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class StudentsTableViewController: UITableViewController {
    @IBAction func onLogout(sender: UIBarButtonItem) {
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
    }
    
    func onLogoutSuccess(data: AnyObject) {
        Utils.clearState()
        print("Logout Success - \(data)")
        Utils.dispatchMainUIThread() { self.dismissViewControllerAnimated(true, completion: nil) }
    }
    
    func onLogoutFailure(error: String?) {
        print("Logout failure - \(error)")
        Utils.dispatchMainUIThread() { self.dismissViewControllerAnimated(true, completion: nil) }
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
            tableView.reloadData()
        }
    }
    
    func onStudentLocationLoaded(data: AnyObject) {
        let parsedData = data as? [String: AnyObject]
        if let a = parsedData?["results"] as? [[String: AnyObject]] {
            OTMHttpClient.studentLocations = StudentInformation.ParseStudentLocations(a)
            Utils.dispatchMainUIThread() { self.tableView.reloadData() }
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
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let l = OTMHttpClient.studentLocations {
            return l.count
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("studentLocationCellId", forIndexPath: indexPath)
        let sl = OTMHttpClient.studentLocations![indexPath.row]
        cell.textLabel?.text = "\(sl.firstName) \(sl.lastName)"
        cell.detailTextLabel?.text = sl.mediaUrl

        if cell.imageView?.image == nil {
            cell.imageView?.image = UIImage(named: "pin")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        
        let sl = OTMHttpClient.studentLocations![indexPath.row]
        Utils.openUrlInBroswer(sl.mediaUrl)
    }
    
    @IBAction func onPinClicked(sender: UIBarButtonItem) {
        print("onPinClicked")
        if let _ = AppDelegate.Instance.userInfo {
            performSegueWithIdentifier("studentLocationFromTableViewSegue", sender: nil)
        }
        else {
            UserInfo.getUser(AppDelegate.Instance.userId!, onError: onUserLoadFailure, onSuccess: onLoadSuccess)
        }
    }
    
    func onLoadSuccess(userInfo: UserInfo) {
        print("onLoadSuccess - \(userInfo)")
        AppDelegate.Instance.userInfo = userInfo
        Utils.dispatchMainUIThread() { self.performSegueWithIdentifier("studentLocationFromTableViewSegue", sender: nil)}
    }
    
    func onUserLoadFailure(error: String) {
        print("onUserLoadFailure - \(error)")
        
        let c = Utils.getAlertController("Loading user information failed.", msg: error)
        Utils.dispatchMainUIThread() { self.presentViewController(c, animated: true, completion: nil) }
    }
}
