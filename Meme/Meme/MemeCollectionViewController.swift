//
//  MemeCollectionViewController.swift
//  Meme
//
//  Created by Arunkumar Chacko on 20/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit

private let reuseIdentifier = "memeCollectionViewCellId"

class MemeCollectionViewController: UICollectionViewController {
    var data : [Meme]!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadModel()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: UIBarButtonItemStyle.Plain, target: self, action: "onAddMemeClicked")
        
        let space: CGFloat = 3.0
        let dimension = (view.frame.width - (2 * space)) / 3
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSizeMake(dimension, dimension)
    }
    
    func onAddMemeClicked() {
        print("onAddMemeClicked")
        performSegueWithIdentifier("editMemeCollectionViewSegueId", sender: nil)
    }
    
    func loadModel() {
         data = AppDelegate.Instance.memeData
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
        loadModel()
        collectionView?.reloadData()
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
        cell.imageView.image = data[indexPath.row].memeImage
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath - \(indexPath.row)")
        
        let c = storyboard?.instantiateViewControllerWithIdentifier("detailsViewController") as! MemeDetailsController
        c.model = data[indexPath.row]
        navigationController?.pushViewController(c, animated: true)
    }
}
