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
    let TEST_LOW_GROUP_ID = "e6rLvyv80V"
    
    var currentGroup: Group? = nil
    var groupArray: [Group] = []
    var convoArray: [Convo] = []
    
    // MARK: - Initialization
    
    init(group: Group?) {

        super.init(style: UITableViewStyle.Plain)
        
        self.currentGroup = group
        
        if self.currentGroup == nil {
            println("currentgroup is nil; this is the root group, I hope")
            var user = PFUser.currentUser()
            if user != nil {
                println("current user exists! Fetch his shit")
                // Fetch groups and convos from network, pin to local datastore
                self.fetchAndPinAllGroups()
                self.fetchAndPinConvosForUser(user)
            }
            
        }
        else {
            println("currentgroup aint nil")
            var g = self.currentGroup!
            self.groupArray = g.getSubGroups()
            self.convoArray = g.getSubConvos()

        }
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
        
//        if self.currentGroup != nil {
//            println("currentgroup aint nil")
//            var g = self.currentGroup!
//            self.groupArray = g.getSubGroups()
//            self.convoArray = g.getSubConvos()
//            
//            
//        }
//        
////        if let g = self.currentGroup as Group! {
////            
////            println("currentgroup is not nil, thats good!")
////            // A group is assigned; we know which groups belong here
////            self.groupArray = g.getSubGroups()
////            self.convoArray = g.getSubConvos()
////            
////        }
//        else {
//
//            println("currentgroup is nil, check current user")
//            var user = PFUser.currentUser()
//            if user != nil {
//                println("current user exists! Fetch his shit")
//                // Fetch groups and convos from network, pin to local datastore
//                self.fetchAndPinAllGroups()
//                self.fetchAndPinConvosForUser(user)
//            }
//        }
    }
    
    // MARK: - Fetch Data
    
    func fetchAndPinAllGroups() {
        
        let query = Group.query()
        query.includeKey(PARENT_GROUP_KEY)
        query.findObjectsInBackgroundWithBlock({(objects:[AnyObject]!, error:NSError!) in
            if (error == nil) {
                println("Fetched \(objects.count) group objects")
                dispatch_async(dispatch_get_main_queue()) {
                    
                    println("Pinnning group objects")
                    PFObject.pinAll(objects)
                    println("Done pinning group objects")
                }
            }
        })
    }
    
    func fetchAndPinConvosForUser(user: PFUser) {
        // Fetch a user's subscribed conversations from the network
        
        let convoQuery = Convo.query()
        convoQuery.whereKey(USERS_KEY, equalTo: user)
        convoQuery.includeKey(GROUP_KEY)
        
        convoQuery.findObjectsInBackgroundWithBlock ({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if (error == nil) {
                println("Fetched \(objects.count) convo objects from network")
                dispatch_async(dispatch_get_main_queue()) {
                    
                    println("Pinnning convo objects")
                    PFObject.pinAll(objects)
                    println("Done pinning convo objects")
                    
                    var convos = objects as [Convo]
                    self.buildGroupHierarchy(convos)
                }
            }
        })
    }
    
    func buildGroupHierarchy(convos: [Convo]) {
        
        for c in convos {
            
            if let group = c.objectForKey("groupId") as? Group {
                
                var topLevelGroup = self.getTopLevelGroup(group)
                if contains(self.groupArray, topLevelGroup) == false {
                
                    // Append new group if not already present
                    self.groupArray.append(topLevelGroup)
                }

            }
        }
        
        self.tableView.reloadData()
        
    }
    
    func getTopLevelGroup(group: Group) -> Group {
        
        // Get parent of this group
        if let parentGroup = group[PARENT_GROUP_KEY] as? Group {
            
            // Fetch the full object from the local datastore
            parentGroup.fetchFromLocalDatastore()
            
            // Recursive call to this function
            return self.getTopLevelGroup(parentGroup)
        }
        
        // If no parent, he is the top level, return it
        return group
    }
    
    // MARK: - Push Data
    
    func createGroupAndSendToParse(groupName: String, parentGroupIdOrNil: String?) {
        var group = Group(name: groupName)
        group.parentId = parentGroupIdOrNil
        
        group.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if success {
                println("Successfully saved Group: \(groupName)")
                self.groupArray.append(group)
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

//        self.promptGroupCreation()
        
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
                        // TODO: Make new group
                        
                        
                        var newGroup = Group(name:title, parentId: self.currentGroup!.objectId)
                        
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if section == GROUP_TABLE_VIEW_SECTION {
            
            return self.groupArray.count
        }

        if section == CONVO_TABLE_VIEW_SECTION {
            
            return self.convoArray.count
        }
        
        return 0
    
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        let cell = UITableViewCell()
        
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            if let name = self.groupArray[indexPath.row].objectForKey("name") as? String {
                cell.textLabel?.text = name
            }
        }
        
        else if indexPath.section == CONVO_TABLE_VIEW_SECTION {
            
            if let name = self.convoArray[indexPath.row].objectForKey("name") as? String {
                cell.textLabel?.text = name
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            var selectedGroup = self.groupArray[indexPath.row] as Group
            
            var viewController = GroupTableViewController(group: selectedGroup)
//            var viewController = GroupTableViewController(nibName: self.nibName, bundle: self.nibBundle)
            
            self.navigationController!.pushViewController(viewController, animated: true)
            
//
//            var query = Group.query()
//            query.fromLocalDatastore()
//            
//            query.whereKey(PARENT_GROUP_KEY, equalTo: selectedGroup)
//            var subGroups: [Group] = query.findObjects() as [Group]
//            println("\(subGroups.count) in the selected group")
//            self.groupArray = subGroups
            
        }
        
        if indexPath.section == CONVO_TABLE_VIEW_SECTION {

            var convo = self.convoArray[indexPath.row]

        }
        
//        self.tableView.reloadData()
        
        return
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if (section == GROUP_TABLE_VIEW_SECTION && self.groupArray.count > 0)
            || (section == CONVO_TABLE_VIEW_SECTION && self.convoArray.count > 0) {
                return TABLE_HEADER_HEIGHT
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))

        if section == GROUP_TABLE_VIEW_SECTION {
            var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
            label.text = "Groups"
            label.textAlignment = NSTextAlignment.Center
            view.addSubview(label)
        }
        
        else if section == CONVO_TABLE_VIEW_SECTION {
            
            var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
            label.text = "Convos"
            label.textAlignment = NSTextAlignment.Center
            view.addSubview(label)
        }
        
        return view
    }
}
