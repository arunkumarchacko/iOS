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
    static let memeFileNamesKey = "MemeFileNames"
    static let memeTopBottomKey = "MemeTopAndBottomTexts"
    
    let topText: String
    let bottomText: String
    let originalImage: UIImage
    let memeImage: UIImage
    let name: String
    
    static func GetMemes() -> [Meme] {
        var result = [Meme]()
        let mf = getMemeNames()
        let topBottomTexts = getSetting(memeTopBottomKey, defaultValue: [String: String]())
        print("TopBottom = \(topBottomTexts)")
        
        for n in mf {
            if let t = getMemeFromName(n, topBottomTexts) {
                result.append(t)
            }
        }
        
        return result
    }
    
    static func getMemeFromName(name: String, _ topBottomTexts: [String: String]) -> Meme? {
        let memeFile = getFileFullPath(name, fileType: "meme").path
        let originalFile = getFileFullPath(name, fileType: "original").path
        
        if let memeFile = memeFile, originalFile = originalFile {
            let oImg = UIImage(contentsOfFile: originalFile)
            let mImg = UIImage(contentsOfFile: memeFile)
            let topText = topBottomTexts["\(name)_top"]
            let bottomText = topBottomTexts["\(name)_bottom"]
            
            if let oImg = oImg, mImg = mImg,  tp = topText, bt = bottomText {
                return Meme(topText: tp, bottomText: bt, originalImage: oImg, memeImage: mImg, name: name)
            }
            else {
                print("Error while reading image file")
            }
        }
        else {
            print("Imagefile not found")
        }
        
        return nil
    }
    
    func save() {
        print("Saving image: Top=\(topText); Bottom=\(bottomText)")
        
        var memeFileNames = Meme.getMemeNames()
        print("MemeFiles=\(memeFileNames)")

        writeJpegFile(Meme.getFileFullPath(name, fileType: "original"), img: originalImage)
        writeJpegFile(Meme.getFileFullPath(name, fileType: "meme"), img: memeImage)
        
        memeFileNames.append(name)
        Meme.setSetting(Meme.memeFileNamesKey, val: memeFileNames)
        
        var topBottomTexts = Meme.getSetting(Meme.memeTopBottomKey, defaultValue: [String: String]())
        topBottomTexts["\(name)_top"] = topText
        topBottomTexts["\(name)_bottom"] = bottomText
        Meme.setSetting(Meme.memeTopBottomKey, val: topBottomTexts)
        
        AppDelegate.addMeme(self)
    }
    
    static func getMemeNames() -> [String] {
        return getSetting(memeFileNamesKey, defaultValue: [String]())
    }
    
    func writeJpegFile(fileName: NSURL, img: UIImage) {
        print("Writing to file \(fileName.path)")
        UIImageJPEGRepresentation(img, 1.0)?.writeToFile(fileName.path!, atomically: true)
    }
    
    static func getFileFullPath(name: String, fileType: String) -> NSURL {
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let pathArray = [dirPath, "\(name)_\(fileType).jpg"]
        return NSURL.fileURLWithPathComponents(pathArray)!
    }
    
    static func getFileName() -> String {
        let currentDateTime = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "ddMMyyyy-HHmmss"
        return formatter.stringFromDate(currentDateTime)
    }
    
    static func getSetting<T>(key : String, defaultValue : T) -> T {
        let t = NSUserDefaults.standardUserDefaults()
        
        if let a: AnyObject = t.objectForKey(key) {
            return a as! T
        }
        else {
            return defaultValue
        }
    }

    static func setSetting(key : String, val : AnyObject)  {
        print("Setting \(key) = \(val)")
        let t = NSUserDefaults.standardUserDefaults()
        t.setObject(val, forKey: key)
        t.synchronize()
    }
    
    static func DeleteItem(toDelete: Meme) {
        print("Deleting image: Top=\(toDelete.topText); Bottom=\(toDelete.bottomText)")
        
        var memeFileNames = Meme.getMemeNames()
        print("MemeFiles=\(memeFileNames)")

        deleteFile(Meme.getFileFullPath(toDelete.name, fileType: "original").path!)
        deleteFile(Meme.getFileFullPath(toDelete.name, fileType: "meme").path!)

        memeFileNames.removeAtIndex(memeFileNames.indexOf(toDelete.name)!)
        
        Meme.setSetting(Meme.memeFileNamesKey, val: memeFileNames)
        
        var topBottomTexts = Meme.getSetting(Meme.memeTopBottomKey, defaultValue: [String: String]())
        topBottomTexts["\(toDelete.name)_top"] = nil
        topBottomTexts["\(toDelete.name)_bottom"] = nil
        Meme.setSetting(Meme.memeTopBottomKey, val: topBottomTexts)
        
        AppDelegate.deleteMeme(toDelete)
        print("\(memeFileNames)")
        print("\(topBottomTexts)")
    }
    
    static func deleteFile(path: String) {
        print("deleting file \(path)")
        let filemgr = NSFileManager.defaultManager()
        
        do {
            try filemgr.removeItemAtPath(path)
        }
        catch {
            print("Delete failed - \(path)")
        }
    }
}
