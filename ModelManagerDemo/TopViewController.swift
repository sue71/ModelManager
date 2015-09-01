//
//  TopViewController.swift
//  ModelManager
//
//  Created by Masaki Sueda on 2015/08/17.
//  Copyright (c) 2015 Masaki Sueda. All rights reserved.
//

import UIKit

class MainTableViewController: UITableViewController {

    let pages: NSArray = ["Todo"]
    let segues: NSArray = ["Todo"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return pages.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = "\(pages[indexPath.row])"

        return cell
    }

    // Cell が選択された場合
    override func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        //performSegueWithIdentifier("Detail",sender: nil)
        performSegueWithIdentifier("\(segues[indexPath.row])",sender: nil)

    }
}