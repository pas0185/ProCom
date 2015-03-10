//
//  GroupTableViewController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit


class GroupTableViewController: UITableViewController, UIAlertViewDelegate {
    
    let TEST_USER_ID = "kRaibtYs3r"
    let HOME_GROUP_ID = "fZRM5e8UVo"
    
    var user: PFUser?
    var pfObjectArray: [PFObject] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchGroupAndAddToArray(HOME_GROUP_ID)
        
        // self.getConvosForUser(TEST_USER_ID)
        
//        if let name = self.group?.name {
//            self.navigationItem.title = name
//        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

    }
    
    // MARK: - Fetch Data from Parse
    func fetchGroupAndAddToArray(groupId: String) {
        
        let query = Group.query()
        query.includeKey(SUB_GROUP_KEY)
        
        query.getObjectInBackgroundWithId(groupId, block:{(PFObject object, NSError error) in
            
            if (error == nil) {
                println("Fetched group with ID: \(groupId)")
                
                self.pfObjectArray.append(object)
                self.tableView.reloadData()
            }
            else {
                println("An error occurred while fetching group with ID: \(groupId)")
            }
        })
    }
    
    // MARK: - Send Data to Parse
    func createGroupAndSendToParse(groupName: String, parentGroupIdOrNil: String?) {
        var group = Group(name: groupName)
        group.parentId = parentGroupIdOrNil
        
        group.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if success {
                println("Successfully saved Group: \(groupName)")
                self.pfObjectArray.append(group)
                self.tableView.reloadData()
            }
            else {
                println("An error occurred while saving Group: \(groupName)")
            }
        }
    }
    
    // MARK: - User Interface Controls

    @IBAction func addButtonPressed(sender: AnyObject) {

        // User tapped 'add' button
        
        self.promptGroupCreation()
        
    }
    
    func promptGroupCreation() {
        
        // Prompt user for name of new group
        var alertView = UIAlertView(title: "New Group", message: "Enter the title of your new group", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        
        alertView.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alertView.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {

        // Made selection on UIAlertView
        
        if buttonIndex == 1 {
            if alertView.title == "New Group" {
                if let field = alertView.textFieldAtIndex(0) {
                    if let title = field.text {
                        // Make new group
                        
                        
                        var newGroup = Group(name:title, parentId: "")
                        
//                        if let parentGroup = self.group {
//                            newGroup.parentId = parentGroup.objectId
//                            parentGroup.addSubGroup(newGroup)
//                        }
//                        else {
//                            // No group assigned for this view yet. Assign the new group
//                            self.assignGroup(newGroup)
//                        }
                        
                        newGroup.saveToNetwork()
                    }
                }
            }
        }
        
        self.tableView.reloadData()
    }
  
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        return self.pfObjectArray.count
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        if let name = self.pfObjectArray[indexPath.row].objectForKey("name") as? String {
            println("name: \(name)")
            cell.textLabel?.text = name
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var object = self.pfObjectArray[indexPath.row]
        let group = object as Group
        
//        self.pfObjectArray.removeAll(keepCapacity: false)
//        self.pfObjectArray.extend(group.subGroups as [PFObject]!)
        
//        if let group = self.pfObjectArray[indexPath.row] as Group {
//            
//            println("selected group: \(group)")
//            println("his subgroups: \(group.subGroups)")
//            
//            self.pfObjectArray.removeAll(keepCapacity: false)
//            
//            self.pfObjectArray.extend(group.subGroups as [PFObject]!)
            for sub in group.subGroups {
                let subGroup: Group = sub as Group
                self.pfObjectArray.append(subGroup)
            }
//        }
        
        self.tableView.reloadData()
        
        return
    }

    // MARK: - Old Code (maybe can be erased)
    
//    override init(style: UITableViewStyle) {
//        super.init(style: style)
//    }
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
//        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    func getConvosForUser(userId: String) {
//        // Fetch conversations for a user
//        
//        let userQuery = PFQuery(className: "_User")
//        
//        var convos = NSArray()
//        
//        userQuery.getObjectInBackgroundWithId(userId, block:{(PFObject user, NSError error) in
//            
//            if (user != nil) {
//                
//                let queryConvo = PFQuery(className: "Convo")
//                queryConvo.whereKey("users", equalTo: user)
//                queryConvo.includeKey("groupId")
//                
//                queryConvo.findObjectsInBackgroundWithBlock ({
//                    (convoArray: [AnyObject]!, error: NSError!) -> Void in
//                    
//                    if (error != nil) {
//                        NSLog("error " + error.localizedDescription)
//                    }
//                    else {
//                        for convo in convoArray {
//                            if let g = convo.objectForKey("groupId") as? PFObject {
//                                var name: String = g["name"] as String
//                                print("Fetched: \(name)")
//                                
//                                var parentId: String = g["parent"] as String
//                                
//                                print("\twith parent ID: \(parentId)\n")
//                                
//                                var localGroup = Group(name: name, parentId: "")
//                                //                                self.array.append(localGroup)
//                                
//                                //                                var objectId: String = g["objectId"] as String
//                                //                                if let p = g.objectForKey("parent") as? PFObject {
//                                //                                    // has a parent group, embed this one within it
//                                //                                }
//                                //                                println(g["name"])
//                                //                                println(g.objectForKey("name"))
//                                //                                groups.append(localGroup)
//                            }
//                        }
//                        
//                        self.tableView.reloadData()
//                    }
//                    // Do something with group list
//                    
//                })
//            }
//        })
//    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
