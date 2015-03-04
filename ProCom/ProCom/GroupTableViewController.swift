//
//  GroupTableViewController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit


class GroupTableViewController: UITableViewController, UIAlertViewDelegate {
    
    let testUserId = "kRaibtYs3r"
    
    // The Group being displayed
    var group: Group?
    
    var user: PFUser?
    
    init(group: Group) {
        self.group = group
        
        super.init()
    }

    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Fetch conversations for a user
    func getConvosForUser(userId: String) {
        
        let userQuery = PFQuery(className: "_User")
        
        var convos = NSArray()
        
        userQuery.getObjectInBackgroundWithId(userId, block:{(PFObject user, NSError error) in
            
            if (user != nil) {
                
                let queryConvo = PFQuery(className: "Convo")
                queryConvo.whereKey("users", equalTo: user)
                queryConvo.includeKey("groupId")
                
                queryConvo.findObjectsInBackgroundWithBlock ({
                    (convoArray: [AnyObject]!, error: NSError!) -> Void in

//                    (NSArray array, NSError error) in
                    
                    if (error != nil) {
                        NSLog("error " + error.localizedDescription)
                    }
                    else {
                        
                        for convo in convoArray {
                            if let g1 = convo.objectForKey("groupId") as? PFObject {
                                var name: String = g1["name"] as String
                                println(g1["name"])
                                println(g1.objectForKey("name"))
                            }
//                            if let group: PFObject = convo["groupId"] as? PFObject {
//                                println(group.objectForKey("name"))
//                            }
                            
                        }
                        
//                        var groups = [PFObject]()
                        
//                        for convo in array {
//                            if let c = convo as? PFObject {
//                                println("convo: \(c)")

//                                println(convo["groupId"].objectId)
//                                var group: PFObject = c.objectForKey("groupId") as PFObject
//                                println("Group: \(group)")
                                
//                                if let parentGroup = c.objectForKey("groupId") as? PFObject {
//                                    NSLog("Group %@", parentGroup)
//                                    groups.append(parentGroup)
//                                }
//                            }
//                        }
                        
                        // Do something with group list
                    }
                })
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getConvosForUser(testUserId)
        
        //----- Test network group retrieval ----//
//        if group == nil {
//            NSLog("Using default testing group")
//            
//            let testingGroupId = "wZKihkdhRB"
//            self.group = Group(networkObjectId: testingGroupId)
//        }
        //--------------------------------------//
        
        if let name = self.group?.name {
            self.navigationItem.title = name
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func assignGroup(group: Group) {
        self.group = group
        self.navigationItem.title = group.name
    }
    
    // MARK: - User Controls
    
    @IBAction func createGroup(sender: AnyObject) {
        
        // Prompt user for name of new group
        var alertView = UIAlertView(title: "New Group", message: "Enter the title of your new group", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            
            if alertView.title == "New Group" {
                if let field = alertView.textFieldAtIndex(0) {
                    if let title = field.text {
                        // Make new group
                        var subGroup = Group(name: title, parentId: "")
                        if let group = self.group {
                            group.addSubGroup(subGroup)
                            subGroup.parentId = group.objectId
                        }
                        else {
                            // No group assigned for this view yet. Assign the new group
                            self.assignGroup(subGroup)
                        }
                        
                        subGroup.saveToNetwork()
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
    
    @IBAction func notificationToggled(sender: AnyObject) {
        
    }
    
    @IBAction func createConvo(sender: AnyObject) {
        
    }
    
    @IBAction func joinExisting(sender: AnyObject) {
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if let group = self.group as Group? {
            if section == 0 {
                if let count = group.subGroups.count as Int? {
                    return count
                }
            }
            
            else if section == 1 {
                if let count = group.convos.count as Int? {
                    return count
                }
            }
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        if let group = self.group as Group? {
            if indexPath.section == 0 {
                if let groupName = group.subGroups[indexPath.row].name {
                    cell.textLabel?.text = groupName + " group"
                }
            }
            else if indexPath.section == 1 {
                if let convoName = group.convos[indexPath.row].title {
                    cell.textLabel?.text = convoName + " convo"
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let group = self.group as Group? {
            if indexPath.section == 0 {
                if let subGroup = group.subGroups[indexPath.row] as Group? {
                    
                    
                    var subGroupViewController = GroupTableViewController(group: subGroup)
                    
                    self.navigationController?.pushViewController(subGroupViewController, animated: true)
                }
            }
            else if indexPath.section == 1 {
                if let convo = group.convos[indexPath.row] as Convo? {

                    // TODO: display ConvoViewController
                }
            }
        }
    
    }
    

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
