//
//  AppDelegate.swift
//  Meme
//
//  Created by Arunkumar Chacko on 16/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var memes: [Meme]?
    
    static var Instance: AppDelegate { get { return (UIApplication.sharedApplication().delegate as! AppDelegate) }}
    
    static func addMeme(meme : Meme) {
        Instance.memes!.append(meme)
    }
    
    static func deleteMeme(meme : Meme) {
        let i = Instance.memes!.indexOf() { $0.name == meme.name }

        if let i = i {
            print("removing item at index \(i); \(Instance.memes!.count)")
            Instance.memes!.removeAtIndex(i)
        }
        else {
            print("Item not found at index \(i)")
        }        
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    var memeData: [Meme]
        {
        get
        {
            if memes == nil {
                memes = Meme.GetMemes()
            }
            
            return memes!
        }
    }
}

