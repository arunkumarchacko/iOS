//
//  ViewController.swift
//  Flick Finder
//
//  Created by Arunkumar Chacko on 23/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    let apiName = "flickr.photos.search"
    let textProperty = "text"
    let latProperty = "lat"
    let lonProperty = "lon"
    
    let BASE_URL = "https://api.flickr.com/services/rest/"
    let METHOD_NAME = "flickr.galleries.getPhotos"
    let API_KEY = "3710c20631f4f80fcacb3584f9bd9c90"
//    let GALLERY_ID = "5704-72157622566655097"
    let EXTRAS = "url_m"
    let DATA_FORMAT = "json"
    let NO_JSON_CALLBACK = "1"
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        longitudeTextField.delegate = self
        latitudeTextField.delegate = self
    }
    
    @IBAction func onSearchClicked(sender: AnyObject) {
        print("\(searchTextField.text)")
        makeSearchRequest(searchTextField.text!)
    }
    
    @IBAction func onLatLongClicked(sender: AnyObject) {
        print("\(longitudeTextField.text); \(latitudeTextField.text)")
        makeGeoSearch(longitudeTextField.text!, latitudeTextField.text!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()
        return true
    }
    
    func makeSearchRequest(searchText: String) {
        getImageFromFlickr(searchText, nil, nil)
    }
    
    func makeGeoSearch(lon: String, _ lat: String) {
        getImageFromFlickr(nil, lat, lon)
    }
    
    func getImageFromFlickr(text: String?, _ lat: String?, _ lon: String?) {
        
        /* 2 - API method arguments */
        var methodArguments = [
//            "method": METHOD_NAME,
            "method": apiName,
            "api_key": API_KEY,
//            "gallery_id": GALLERY_ID,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK
        ]
        
        if let t = text {
            methodArguments[textProperty] = t
        }
        else {
            methodArguments[latProperty] = lat!
            methodArguments[lonProperty] = lon!
        }
        
        /* 3 - Initialize session and url */
        let session = NSURLSession.sharedSession()
        let urlString = BASE_URL + escapedParameters(methodArguments)
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        /* 4 - Initialize task for getting data */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 6 - Parse the data (i.e. convert the data to JSON and look for values!) */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            print("\(parsedResult)")
            
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult["stat"] as? String where stat == "ok" else {
                print("Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            /* GUARD: Are the "photos" and "photo" keys in our result? */
            guard let photosDictionary = parsedResult["photos"] as? NSDictionary,
                photoArray = photosDictionary["photo"] as? [[String: AnyObject]] else {
                    print("Cannot find keys 'photos' and 'photo' in \(parsedResult)")
                    return
            }
            
            /* 7 - Generate a random number, then select a random photo */
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
            let photoDictionary = photoArray[randomPhotoIndex] as [String: AnyObject]
            let photoTitle = photoDictionary["title"] as? String /* non-fatal */
            
            /* GUARD: Does our photo have a key for 'url_m'? */
            guard let imageUrlString = photoDictionary["url_m"] as? String else {
                print("Cannot find key 'url_m' in \(photoDictionary)")
                return
            }
            
            /* 8 - If an image exists at the url, set the image and title */
            let imageURL = NSURL(string: imageUrlString)
            if let imageData = NSData(contentsOfURL: imageURL!) {
                dispatch_async(dispatch_get_main_queue(), {
                    print("\(photoTitle)")
                    self.imageView.image = UIImage(data: imageData)
//                    self.photoTitle.text = photoTitle ?? "(Untitled)"
                    self.titleLabel.text = photoTitle ?? "(Untitled)"
                })
            } else {
                print("Image does not exist at \(imageURL)")
            }
            
            

        }
        
        
        
        
        
        task.resume()
    }
    
    func escapedParameters(parameters: [String : String]) -> String {
        

        var queryItems = parameters.map { NSURLQueryItem(name:$0, value:$1)}
        var components = NSURLComponents()
        components.queryItems = queryItems
        print("\(components.percentEncodedQuery)")
        return components.percentEncodedQuery ?? ""
        
//        var urlVars = [String]()
//        
//        for (key, value) in parameters {
//            
//            /* Make sure that it is a string value */
//            let stringValue = "\(value)"
//            
//            /* Escape it */
//            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
//            
//            /* Append it */
//            urlVars += [key + "=" + "\(escapedValue!)"]
//            
//        }
//        
//        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}

