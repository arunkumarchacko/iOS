//
//  LoginViewController.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 25/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    // If user taps on the text field while the keyboard is shown, the keyboard is not dismissed.
    // This field is used to make sure that we do not reposition the keyboard if it is already repositioned.
    var viewRepositioned = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let hasFbToken = FBSDKAccessToken.currentAccessToken() != nil
        fbLoginButton.enabled = !hasFbToken
        enableDisableLoginButton()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.delegate = self
        
        if let a = FBSDKAccessToken.currentAccessToken() {
            // Already logged in to FB. Auto login user.
            loginFacebook(a.tokenString!)
        }
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        subscribeNotifications()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeNotifications()
    }
    
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
            print("FB login failed \(e)")
            onError("Facebook login operation failed")
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
        print("loginButtonDidLogOut")
    }
    
    func subscribeNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("keyboardWillShow")
        if viewRepositioned {
            print("View is already repositioned")
            return
        }
        
        viewRepositioned = true
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        print("keyboardWillHide")
        if (viewRepositioned) {
            view.frame.origin.y += getKeyboardHeight(notification)
            viewRepositioned = false
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let keyboardSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height / 4
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
