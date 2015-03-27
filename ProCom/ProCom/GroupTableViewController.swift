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
    
    var groupActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var convoActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    // MARK: - Initialization
    
    init(group: Group?) {

        super.init(style: UITableViewStyle.Grouped)
        
        self.currentGroup = group
        
        if self.currentGroup == nil {
            println("currentgroup is nil; this is the root group")
            var user = PFUser.currentUser()
            if user != nil {
                println("current user exists! Fetch his groups")
                // Fetch groups and convos from network, pin to local datastore

                self.groupActivityIndicator.startAnimating()
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
        
        if let title = self.currentGroup?.objectForKey(NAME_KEY) as? String {
            println("TITLE = \(title)")
            self.navigationItem.title = title
        }
        
        // Add an 'add group' button to navbar
        var addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addGroupButtonClicked")
        self.navigationItem.rightBarButtonItem = addButton
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
        
        self.groupActivityIndicator.stopAnimating()
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
    
    func addGroupButtonClicked() {

        self.promptChooseGroupOrConvoCreation()
    }
    
    func promptChooseGroupOrConvoCreation() {
        
        // Prompt user to create a new convo or new group
        let alert = UIAlertController(title: "Start Something New", message: "Would you like to start a new Group or a new Convo?", preferredStyle: UIAlertControllerStyle.Alert)

        // Configure alert actions
        var newGroupAction = UIAlertAction(title: "New Group", style: .Default, handler: {(alertAction:UIAlertAction!) in
            self.promptGroupCreation()
        })
        
        var newConvoAction = UIAlertAction(title: "New Convo", style: .Default, handler: {(alertAction:UIAlertAction!) in
            self.promptConvoCreation()
        })
        
        var cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        // Add actions to alert
        alert.addAction(newGroupAction)
        alert.addAction(newConvoAction)
        alert.addAction(cancelAction)
        
        // Display alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func promptGroupCreation() {
        
        // Prompt user for name of new group
        let alert = UIAlertController(title: "Create New Group", message: "Enter a name for your group", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            
            textField.autocapitalizationType = .Words
            textField.autocorrectionType = .Yes
        
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
            let textField = alert.textFields![0] as UITextField
            let groupname = textField.text
            println(groupname)
            
            var newGroup = Group()
            newGroup[NAME_KEY] = groupname
            
            // TODO: be able to add a new group with a nil parent group
            newGroup[PARENT_GROUP_KEY] = self.currentGroup
            newGroup.saveInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    println("Successfully saved new group: \(groupname)")
                    self.groupArray.append(newGroup)
                    newGroup.pin()
                    self.tableView.reloadData()
                }
                else {
                    println("Failed to save new group: \(groupname)")
                }
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
  
    func promptConvoCreation() {
        
        // Prompt user for name of new convo
        let alert = UIAlertController(title: "Create New Convo", message: "Enter a name for your convo", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler({(textField: UITextField!) in
            
            textField.autocapitalizationType = .Words
            textField.autocorrectionType = .Yes
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
            let textField = alert.textFields![0] as UITextField
            let convoName = textField.text
            println(convoName)
            
            var newConvo = Convo()
            
            newConvo[NAME_KEY] = convoName
            newConvo[GROUP_KEY] = self.currentGroup
            var relation = newConvo.relationForKey(USERS_KEY)
            relation.addObject(PFUser.currentUser())
            
            newConvo.saveInBackgroundWithBlock {
                (success: Bool, error: NSError!) -> Void in
                if (success) {
                    println("Successfully saved new convo: \(convoName)")
                    self.convoArray.append(newConvo)
                    newConvo.pin()
                    self.tableView.reloadData()
                }
                else {
                    println("Failed to save new convo: \(convoName)")
                }
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        
        return 2
        
        
//        var numSections: Int = 0
//        if self.groupArray.count > 0 {
//            numSections++
//        }
//        
//        if self.convoArray.count > 0 {
//            numSections++
//        }
//        
//        return numSections
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

        let cell = UITableViewCell()
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            if let name = self.groupArray[indexPath.row].objectForKey(NAME_KEY) as? String {
                cell.textLabel?.text = name
            }
        }
        
        else if indexPath.section == CONVO_TABLE_VIEW_SECTION {
            
            if let name = self.convoArray[indexPath.row].objectForKey(NAME_KEY) as? String {
                cell.textLabel?.text = name
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            var selectedGroup = self.groupArray[indexPath.row] as Group
            
            var groupView = GroupTableViewController(group: selectedGroup)
            
            self.navigationController!.pushViewController(groupView, animated: true)
        }
        
        else if indexPath.section == CONVO_TABLE_VIEW_SECTION {
            
            var convo = self.convoArray[indexPath.row]
            println("Convo was selected: \(convo)")
            
            var convoView = BlurbTableViewController(convo: convo)
            
            self.navigationController?.pushViewController(convoView, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return TABLE_HEADER_HEIGHT
        
//        if (section == GROUP_TABLE_VIEW_SECTION && self.groupArray.count > 0)
//            || (section == CONVO_TABLE_VIEW_SECTION && self.convoArray.count > 0) {
//                return TABLE_HEADER_HEIGHT
//        }
//        
//        return 0
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
        var activityWidth = self.groupActivityIndicator.frame.width
        var activityFrame = CGRectMake(view.frame.width - activityWidth - 14, 0, activityWidth, view.frame.height)
        
        if section == GROUP_TABLE_VIEW_SECTION {
            var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
            label.text = "Groups"
            label.textAlignment = NSTextAlignment.Center
            view.addSubview(label)
            
            self.groupActivityIndicator.frame = activityFrame
            view.addSubview(self.groupActivityIndicator)
        }
        
        else if section == CONVO_TABLE_VIEW_SECTION {
            
            var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
            label.text = "Convos"
            label.textAlignment = NSTextAlignment.Center
            view.addSubview(label)
            
            self.convoActivityIndicator.frame = activityFrame
            view.addSubview(self.convoActivityIndicator)
        }
        
        return view
    }
}
