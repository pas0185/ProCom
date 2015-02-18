//
//  GroupTableViewController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class GroupTableViewController: UITableViewController {

    // Name of this group
    var name: String?
    
    // Subgroups - Section 0
    var subGroups = [Group]()
    
    // Conversations - Section 1
    var convos = [Convo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let name = self.name {
            self.navigationItem.title = name
        }
        else {
            self.navigationItem.title = "Groups"
        }
        
        subGroups.append(Group(name: "Abraid"))
        subGroups.append(Group(name: "Questions"))
        subGroups.append(Group(name: "Meetings"))

        convos.append(Convo(title: "Suggestions"))
        convos.append(Convo(title: "Fun Talk"))

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - User Controls
    
    func createButtonPressed() {
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if section == 0 {
            return subGroups.count
        }
        else if section == 1 {
            return convos.count
        }
        
        return 0
    }

//    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 80
//        }
//        
//        return 0
//    }
//    
//    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if section == 0 {
//            
//            // TODO: UICollectionView
//            var margin = 5.0
//            var buttonWidth = 75 as CGFloat// (tableView.frame.size.width / 4.0) - 10.0// - (2.0 * margin) as Double
//            
//            let toolbar = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 50))
//            toolbar.backgroundColor = UIColor.blackColor()
//            
//            let createGroupButton = UIButton(frame: CGRectMake(5, 5, buttonWidth, 60))
//            createGroupButton.backgroundColor = UIColor.redColor()
//            createGroupButton.setTitle("New Group", forState: .Normal)
//            
//            let joinGroupButton = UIButton(frame: CGRectMake(135, 5, buttonWidth, 60))
//            joinGroupButton.backgroundColor = UIColor.redColor()
//            joinGroupButton.setTitle("Join Existing", forState: .Normal)
//            
//            let createConvoButton = UIButton(frame: CGRectMake(265, 5, buttonWidth, 60))
//            createConvoButton.backgroundColor = UIColor.redColor()
//            createConvoButton.setTitle("New Convo", forState: .Normal)
//            
//            let toggleSwitch = UISwitch(frame: CGRectMake(395, 5, buttonWidth, 60))
//            
//            toolbar.addSubview(createGroupButton)
//            toolbar.addSubview(joinGroupButton)
//            toolbar.addSubview(createConvoButton)
//            toolbar.addSubview(toggleSwitch)
//            
//            return toolbar
//            
//        }
//        
//        return nil
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        let cell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "[GROUP]: " + self.subGroups[indexPath.row].name!
        }
        else if indexPath.section == 1 {
            cell.textLabel?.text = "[CONVO]: " + self.convos[indexPath.row].title!
        }
        
        return cell
    }
    
//    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
//        NSLog("You selected cell #\(indexPath.row)!")
//    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
