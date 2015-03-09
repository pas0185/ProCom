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
    
    // The Group being displayed
    var group: Group?
    
    var user: PFUser?
    
    var array = [Group]()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.getConvosForUser(TEST_USER_ID)
        
        self.getNestedGroups(HOME_GROUP_ID)
        
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
        
        self.tableView.reloadData()
    }
    
    // MARK: - Parse Networking
    func getNestedGroups(groupId: String) {
        let query = PFQuery(className: "Group");
        
        query.includeKey("subGroups");
        
        query.getObjectInBackgroundWithId(groupId, block:{(PFObject group, NSError error) in
            if (error == nil) {
                // Got THIS group
                
                if let homeName = group["name"] as? String {
                    
                    var localHomeGroup = Group(name: homeName)
                        
                    if let subGroups1 = group.objectForKey("subGroups") as [PFObject]! {
                        
                        // Got its children groups
                        
                        for sub1 in subGroups1 {
                            if let subName = sub1["name"] as? String {
                                
                                
                                let subGroupA = Group(name: subName)
                                
                                localHomeGroup.subGroups.append(subGroupA)
                            }
                        }
                    }
                    
                    self.array.append(localHomeGroup)
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func getConvosForUser(userId: String) {
        // Fetch conversations for a user
        
        let userQuery = PFQuery(className: "_User")
        
        var convos = NSArray()
        
        userQuery.getObjectInBackgroundWithId(userId, block:{(PFObject user, NSError error) in
            
            if (user != nil) {
                
                let queryConvo = PFQuery(className: "Convo")
                queryConvo.whereKey("users", equalTo: user)
                queryConvo.includeKey("groupId")
                
                queryConvo.findObjectsInBackgroundWithBlock ({
                    (convoArray: [AnyObject]!, error: NSError!) -> Void in
                    
                    if (error != nil) {
                        NSLog("error " + error.localizedDescription)
                    }
                    else {
                        for convo in convoArray {
                            if let g = convo.objectForKey("groupId") as? PFObject {
                                var name: String = g["name"] as String
                                print("Fetched: \(name)")
                                
                                var parentId: String = g["parent"] as String
                                
                                print("\twith parent ID: \(parentId)\n")
                                
                                var localGroup = Group(name: name, parentId: "")
                                self.array.append(localGroup)

//                                var objectId: String = g["objectId"] as String
//                                if let p = g.objectForKey("parent") as? PFObject {
//                                    // has a parent group, embed this one within it
//                                }
//                                println(g["name"])
//                                println(g.objectForKey("name"))
//                                groups.append(localGroup)
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                    // Do something with group list
                    
                })
            }
        })
    }

    // MARK: - User Controls

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
                        
                        if let parentGroup = self.group {
                            newGroup.parentId = parentGroup.objectId
                            parentGroup.addSubGroup(newGroup)
                        }
                        else {
                            // No group assigned for this view yet. Assign the new group
                            self.assignGroup(newGroup)
                        }
                        
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
        
        return self.array.count
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        cell.textLabel?.text = self.array[indexPath.row].name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if let group = self.array[indexPath.row] as Group? {
            self.array.removeAll(keepCapacity: false)
            
            for sub in group.subGroups {
                self.array.append(sub)
            }
        }
        
        self.tableView.reloadData()
        
        return
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
