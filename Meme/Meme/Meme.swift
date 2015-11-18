//
//  Meme.swift
//  Meme
//
//  Created by Arunkumar Chacko on 17/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import Foundation
import UIKit

internal struct Meme {
    let memeFileNamesKey = "MemeFileNames"
    let topText: String
    let bottomText: String
    let originalImage: UIImage
    let memeImage: UIImage
    
    func save() {
        print("Saving image: Top=\(topText); Bottom=\(bottomText)")
        
        var memeFileNames = getSetting(memeFileNamesKey, defaultValue: [String]())
        print("MemeFiles=\(memeFileNames)")

        let f = getFileName()

        writeJpegFile(getPathToSave(f, fileType: "original"))
        writeJpegFile(getPathToSave(f, fileType: "meme"))
        
        memeFileNames.append(f)
        setSetting(memeFileNamesKey, val: memeFileNames)
    }
    
    func writeJpegFile(fileName: NSURL) {
        print("Writing to file \(fileName.path)")
        UIImageJPEGRepresentation(originalImage, 1.0)?.writeToFile(fileName.path!, atomically: true)
    }
    
    func getPathToSave(name: String, fileType: String) -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.PicturesDirectory, .UserDomainMask, true)[0] as String
        let pathArray = [dirPath, "\(name)_\(fileType).jpg"]
        return NSURL.fileURLWithPathComponents(pathArray)!
    }
    
    func getFileName() -> String {
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        return formatter.stringFromDate(currentDateTime)
    }
    
    func getSetting<T>(key : String, defaultValue : T) -> T {
        let t = NSUserDefaults.standardUserDefaults()
        
        if let a: AnyObject = t.objectForKey(key) {
            return a as! T
        }
        else {
            return defaultValue
        }
    }

    func setSetting(key : String, val : AnyObject)  {
        print("Setting \(key) = \(val)")
        let t = NSUserDefaults.standardUserDefaults()
        t.setObject(val, forKey: key)
        t.synchronize()
    }
}
