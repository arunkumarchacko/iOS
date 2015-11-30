//
//  ViewController.swift
//  Facebook Test
//
//  Created by Arunkumar Chacko on 29/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let d = "2015-11-02T19:06:10.766Z"
        print("Input = \(d)")
//        let b = FBSDKLoginButton()
//        b.readPermissions = ["public_profile"]
//        b.center = self.view.center
//        self.view.addSubview(b)
//        
//        b.delegate = self
//        
//        if FBSDKAccessToken.currentAccessToken() != nil {
//            print("Current token \(FBSDKAccessToken.currentAccessToken().tokenString); \(FBSDKProfile.currentProfile())")
//
//            
//            let tok = FBSDKAccessToken.currentAccessToken().tokenString!
//            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
//            request.HTTPMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Accept")
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(tok);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
//            let session = NSURLSession.sharedSession()
//            let task = session.dataTaskWithRequest(request) { data, response, error in
//                print("dataTaskWithRequest")
//                if error != nil {
//                    // Handle error...
//                    return
//                }
//                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
//                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
//                
//                dispatch_async(dispatch_get_main_queue()) { self.returnUserData()}
//            }
//            task.resume()
//        }
    }

    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("first_name")
                

                print("User Email is: \(userEmail)")
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("didCompleteWithResult - \(result); \(error)")
        
        let p = "name"
       // print("\(result.dictionaryWithValuesForKeys([p]))")
        print("Token = \(result.token.tokenString); \(result.grantedPermissions); \(result.valueForKey(p))")
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("loginButtonDidLogOut")
    }

}

