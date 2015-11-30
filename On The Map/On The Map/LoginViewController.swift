//
//  LoginViewController.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 25/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let hasFbToken = FBSDKAccessToken.currentAccessToken() != nil
//        self.loginButton.enabled = !hasFbToken
        self.fbLoginButton.enabled = !hasFbToken
        enableDisableLoginButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.delegate = self
        
        if let a = FBSDKAccessToken.currentAccessToken() {
            loginFacebook(a.tokenString!)
        }
    }

//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        if let a = FBSDKAccessToken.currentAccessToken() {
//            loginFacebook(a.tokenString!)
//        }
//    }
    
    @IBAction func onLoginButtonClicked(sender: AnyObject) {
        print("onLoginButtonClicked clicked")
        login()
    }
    
    @IBAction func onTextChanged(sender: UITextField) {
        enableDisableLoginButton()
    }
    
    func enableDisableLoginButton() {
        loginButton.enabled = emailTextField.text?.characters.count > 0 && passwordTextField.text?.characters.count > 0
    }
    
    func login() {
        let r = UdacityLoginContext(userName: emailTextField.text!, passwd: passwordTextField.text!)
        OTMHttpClient.invokeRequest(r, onSuccess: onSuccess, onError: onError)
    }
    
    func onError(error: String) {
        print("onError - \(error)")
        let c = Utils.getAlertController("Login failed", msg: error)
        
        Utils.dispatchMainUIThread() { self.presentViewController(c, animated: true, completion: nil) }
    }
    
    func onSuccess(result: AnyObject) {
        print("onSuccess: \(result)")
        
        let r = result as? [String: [String: AnyObject]]
        if let userId = r?["account"]?["key"]  as? String {
            print("userId = \(userId)")
  
            AppDelegate.Instance.userId = userId
        }
        
        Utils.dispatchMainUIThread() { self.segueToStudentsMap() }
    }
    
    func segueToStudentsMap() {
        print("Entering segueToStudentsMap")
        performSegueWithIdentifier("mapTabBarSegue", sender: nil)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("didCompleteWithResult")
        if let e = error {
            onError(e.description)
            return
        }
        
        if let a = FBSDKAccessToken.currentAccessToken() {
            loginFacebook(a.tokenString!)
        }
        else {
            onError("Facebook login operation failed")
        }
    }
    
    func loginFacebook(token: String) {
        print("loginFacebook - \(token)")
        let r = UdacityFacebookLoginContext(accessToken: token)
        OTMHttpClient.invokeRequest(r, onSuccess: onSuccess, onError: onError)
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
    }
}
