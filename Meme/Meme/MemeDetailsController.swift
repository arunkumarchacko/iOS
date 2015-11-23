//
//  MemeDetailsController.swift
//  Meme
//
//  Created by Arunkumar Chacko on 21/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit

class MemeDetailsController: UIViewController {

    var model : Meme!
    
    @IBOutlet weak var imageView: UIImageView!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = model?.memeImage
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: "onEditClicked")
    }
    
    override func viewWillAppear(animated: Bool) {
        tabBarController?.tabBar.hidden = true
    }

    override func viewWillDisappear(animated: Bool) {
        tabBarController?.tabBar.hidden = false
    }
    
    func onEditClicked() {
        print("Edit clicked")
        
        let c = storyboard?.instantiateViewControllerWithIdentifier("editMemeStoryBoardId") as! MemeViewController
        c.model = model
        navigationController?.pushViewController(c, animated: true)
    }
}
