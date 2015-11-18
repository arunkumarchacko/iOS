//
//  MemeViewController.swift
//  Meme
//
//  Created by Arunkumar Chacko on 16/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit

internal class MemeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var imageView: UIImageView!    
    @IBOutlet weak var topTextView: UITextField!
    @IBOutlet weak var bottomTextview: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)

        set(topTextView)
        set(bottomTextview)
        
        shareButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeNotifications()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeNotifications()
    }
    
    @IBAction func onPickClicked(sender: UIBarButtonItem) {
        let imgPicker = UIImagePickerController()

        imgPicker.sourceType = sender.tag == 1 ? .PhotoLibrary: .Camera
        imgPicker.delegate = self
        
        presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func onShareClicked(sender: AnyObject) {
        let memedImage = generateMemedImage()
        let avc = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)

        avc.completionWithItemsHandler = {
            (_, success, _, _) in
            success ? self.saveMeme(memedImage) : print("Not saving item since sharing failed or cancelled.")
        }
        
        presentViewController(avc, animated: true, completion: nil)
    }    

    func foo(a: String, b: Bool) {
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Picked - \(info)")
        
        if let img = info[ UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = img
            shareButton.enabled = true
        }
        
        dismissImagePicker(picker)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("Picker cancelled")
        dismissImagePicker(picker)
    }
    
    func dismissImagePicker(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func subscribeNotifications() {
        print("subscribeNotifications")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeNotifications() {
        print("unsubscribeNotifications")
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        print("Received - UIKeyboardWillShowNotification")
        
        if topTextView.editing {
            // No need to reposition keyboard for top textview
            return
        }
        
        view.frame.origin.y -= getKeyboardHeight(notification)
    }

    func keyboardWillHide(notification: NSNotification) {
        print("Received - UIKeyboardWillHideNotification")
        
        if topTextView.editing {
            // No need to reposition keyboard for top textview
            return
        }
        
        view.frame.origin.y += getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func set(textField : UITextField) {
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.blueColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : 5]
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .Center
    }
    
    func generateMemedImage() -> UIImage
    {
        // So that Toolbar is not captured in the Meme image.
        toolBar.hidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        toolBar.hidden = false
        
        return memedImage
    }
    
    func saveMeme(image: UIImage) {
        print("Saving meme")
        let m = Meme(topText: topTextView.text!, bottomText: bottomTextview.text!, originalImage: imageView.image!, memeImage: image)
        m.save()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
        editing = true
    }    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var newText = textField.text! as NSString
        newText = newText.stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
        textField.text = newText as String
        
        return false
    }
}

