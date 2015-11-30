//
//  MemeTableViewController.swift
//  Meme
//
//  Created by Arunkumar Chacko on 19/11/15.
//  Copyright © 2015 Chacko Apps. All rights reserved.
//

import UIKit

internal class MemeTableViewController: UITableViewController {
    var data: [Meme]!
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadModel()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+", style: UIBarButtonItemStyle.Plain, target: self, action: "onAddMemeClicked")
    }

    func reloadModel() {
        data = AppDelegate.Instance.memeData
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        tabBarController?.tabBar.hidden = false
    }
    
    func onAddMemeClicked() {
        print("onAddMemeClicked")
        performSegueWithIdentifier("editMemeStoryboardSegueId", sender: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberofrowsinsection \(data.count)")
        return data.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tableViewCellId", forIndexPath: indexPath)
        cell.textLabel?.text = "\(data[indexPath.row].topText)...\(data[indexPath.row].bottomText)"
        cell.imageView?.image = data[indexPath.row].memeImage
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("didSelectRowAtIndexPath - tableview - \(indexPath.row) - \(data[indexPath.row])")
        let c = storyboard?.instantiateViewControllerWithIdentifier("detailsViewController") as! MemeDetailsController
        c.model = data[indexPath.row]

        navigationController?.pushViewController(c, animated: true)
    }
    
    func reload() {
        data = AppDelegate.Instance.memeData
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let itemToDelete = data[indexPath.row]
            Meme.DeleteItem(itemToDelete)
            reloadModel()
            
            print("MemeCount = \(data.count)")
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}
