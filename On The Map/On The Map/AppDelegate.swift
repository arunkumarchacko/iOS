//
//  AppDelegate.swift
//  On The Map
//
//  Created by Arunkumar Chacko on 25/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var userInfo: UserInfo?
    var userId: String?
    
    static var Instance: AppDelegate { get { return UIApplication.sharedApplication().delegate as! AppDelegate }}
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions);
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
}

