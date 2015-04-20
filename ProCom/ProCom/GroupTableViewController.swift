//
//  GroupTableViewController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit
import CoreData

class GroupTableViewController: UITableViewController, UIAlertViewDelegate {

    
    var mgdGroups = [ManagedGroup]()
    var mgdConvos = [ManagedConvo]()
    var group: ManagedGroup?
    
    
    var currentGroup: Group? = nil
//    var groupArray: [Group] = []
//    var convoArray: [Convo] = []

    var groupActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var convoActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Initialization
    
    init(group: ManagedGroup?) {
        super.init(style: UITableViewStyle.Grouped)
        
        self.group = group
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
        
        // Convos from Core Data
        self.convoActivityIndicator.startAnimating()
        CoreDataManager.sharedInstance.fetchConvos(forGroup: self.currentGroup) {
            (convos: [ManagedConvo]) in
            
            println("Received from CoreDataManager: \(convos.count) convos")
            self.convoActivityIndicator.stopAnimating()
            
            // Assign these convos and reload TableView
            self.mgdConvos = convos
            self.tableView.reloadData()
        }
        
        // Groups from Core Data
        self.groupActivityIndicator.startAnimating()
        CoreDataManager.sharedInstance.fetchGroups(forGroup: self.currentGroup) {
            (groups: [ManagedGroup]) in
            
            println("Received from CoreDataManager: \(groups.count) groups")
            self.groupActivityIndicator.stopAnimating()
            
            // Assign these groups and reload TableView
            self.mgdGroups = groups
            self.tableView.reloadData()
        }
        
        
        // Add an 'add group' button to navbar
        var addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addGroupButtonClicked")
        self.navigationItem.rightBarButtonItem = addButton
        
    }
    
    // MARK: - Convos (Network and Core Data)
    
//    func fetchConvos(user: PFUser, completionBlock: () -> Void) {
//        // Fetch a user's subscribed conversations
//        
//        // Get all from Core Data
//        var coreConvos: [NSManagedObject] = self.fetchConvosFromCoreData(user)
//        
//        // Get all from Network that are NOT in Core Data, and put them into Core
//        self.fetchConvosFromNetworkAndSaveToCoreData(user, existingConvos: coreConvos)
//        
//        completionBlock()
//    }
//    
//    func fetchConvosFromCoreData(user: PFUser) -> [NSManagedObject] {
//        // Return all Convos saved in Core Data
//        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        
//        let fetchRequest = NSFetchRequest(entityName: "Convo")
//        var error: NSError?
//        
//        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
//        
//        if let results = fetchedResults {
//            println("Fetched \(results.count) Convos from Core Data:")
//        }
//        else {
//            println("Could not fetch \(error), \(error!.userInfo)")
//        }
//        
//        return fetchedResults!
//    }
    
    func fetchConvosFromNetworkAndSaveToCoreData(user: PFUser, existingConvos: [NSManagedObject]) {
        // Get all unfetched convos from the Network and save them to Core Data
        
        let convoQuery = Convo.query()
        convoQuery.whereKey(USERS_KEY, equalTo: user)
        
        // Don't fetch Convos we already have
        var existingConvoIds: [String] = []
        for convo in existingConvos as! [ManagedConvo] {
            existingConvoIds.append(convo.pfId)
        }
        convoQuery.whereKey(OBJECT_ID_KEY, notContainedIn: existingConvoIds)
        
        convoQuery.includeKey(GROUP_KEY)
        
        convoQuery.findObjectsInBackgroundWithBlock ({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if (error == nil) {
                println("Fetched \(objects.count) convos from Network")
                dispatch_async(dispatch_get_main_queue()) {
                    
                    PFObject.pinAll(objects)

                    let currentInstallation = PFInstallation.currentInstallation()
                    
                    var convos = objects as! [Convo]
                    
                    for convo in convos {
                        convo.saveToCore()

                        if let parentGroup = convo.objectForKey("groupId") as? Group {
                            
                            parentGroup.saveToCore()
                        }

                        if let channelName = convo.getChannelName() {
                            println("Subscribing to convo channel: \(channelName)")
                            currentInstallation.addUniqueObject(channelName, forKey: "channels")
                        }
                    }
                    currentInstallation.saveInBackgroundWithBlock(nil)
                    
                    var coreConvos = Convo.convosFromNSManagedObjects(existingConvos)
                    convos.extend(coreConvos)
                    
                    // Now go fetch the groups for the new convos
//                    self.fetchGroups(convos)
                }
            }
        })
    }
    
    // MARK: - Groups (Network and Core Data)
    
//    func fetchGroups(convos: [Convo]) {
//        // Fetch the Groups that build up the hierarchy of the given Convos
//        
//        // Fetch all Groups already in Core Data
//        var coreGroups: [NSManagedObject] = self.fetchGroupsFromCoreData()
//        
//        // Get parent groups of the provided Convos
//        var parentGroups: [Group] = []
//        for convo in convos {
//            
//            if let parentGroup = convo.objectForKey("groupId") as? Group {
//
//                parentGroups.append(parentGroup)
//                
////                var topLevelGroup = self.getTopLevelGroup(parentGroup)
////                if contains(self.groupArray, topLevelGroup) == false {
////                    
////                    // Append new group if not already present
////                    self.groupArray.append(topLevelGroup)
////                }
//            }
////            else {
////                println("Failed to get parent group for a convo: \(convo)")
////            }
//        }
//        
//        println("Using \(convos.count) convos; successfully found \(parentGroups.count) groups")
//        // Recursively fetch hierarchy
//        
//        var allGroups = Group.groupsFromNSManagedObjects(coreGroups)
//        allGroups.extend(parentGroups)
//        println("All groups: \(allGroups)")
//        
//        // ************** //
//        // ***BOOKMARK*** //
//        // ************** //
//        
//        
//        self.groupActivityIndicator.stopAnimating()
//        self.tableView.reloadData()
//    }
//    
//    func fetchGroupsFromCoreData() -> [NSManagedObject] {
//        // Return all Groups saved in Core Data
//        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext!
//        
//        let fetchRequest = NSFetchRequest(entityName: "Group")
//        var error: NSError?
//        
//        let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]?
//        
//        if let results = fetchedResults {
//            println("Fetched \(results.count) Groups from Core Data:")
//        }
//        else {
//            println("Could not fetch \(error), \(error!.userInfo)")
//        }
//        
//        return fetchedResults!
//        
//    }
    
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
    
    
    
    
//    func fetchAndPinAllGroups() {
//        
//        let query = Group.query()
//        query.includeKey(PARENT_GROUP_KEY)
//        query.findObjectsInBackgroundWithBlock({(objects:[AnyObject]!, error:NSError!) in
//            if (error == nil) {
//                println("Fetched \(objects.count) group objects")
//                dispatch_async(dispatch_get_main_queue()) {
//                    
//                    println("Pinnning group objects")
//                    PFObject.pinAll(objects)
//                    println("Done pinning group objects")
//                }
//            }
//        })
//    }
    
    
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
            let textField = alert.textFields![0] as! UITextField
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
                    
                    // FIXME
//                    CoreDataManager.addNewGroup(group)
                    
//                    self.groupArray.append(newGroup)
//                    newGroup.pin()
//                    self.tableView.reloadData()
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
            let textField = alert.textFields![0] as! UITextField
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
                    // FIXME
                    // CoreDataManager.addNewConvo(convo)
                    
//                    self.convoArray.append(newConvo)
//                    newConvo.pin()
//                    self.tableView.reloadData()
                }
                else {
                    println("Failed to save new convo: \(convoName)")
                }
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func sendPushToMembers() {
        var query = PFInstallation.query()
        query.whereKey("deviceType", equalTo: "ios")
        var error = NSErrorPointer()
        PFPush.sendPushMessageToQuery(query, withMessage: "TEST MESSAGE", error: error)
        
        if error != nil {
            println("Error sending push to members")
        }
        else {
            println("Successfully sent push to members")
        }
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if section == GROUP_TABLE_VIEW_SECTION {
            
            return self.mgdGroups.count
//            return self.groupArray.count
        }

        if section == CONVO_TABLE_VIEW_SECTION {
            
            return self.mgdConvos.count
//            return self.convoArray.count
        }
        
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            if let name = self.mgdGroups[indexPath.row].name {
                cell.textLabel?.text = name
            }
            
//            if let name = self.groupArray[indexPath.row].objectForKey(NAME_KEY) as? String {
//                cell.textLabel?.text = name
//            }
        }
        
        else if indexPath.section == CONVO_TABLE_VIEW_SECTION {
            
            if let name = self.mgdConvos[indexPath.row].name {
                cell.textLabel?.text = name
            }
            
//            if let name = self.convoArray[indexPath.row].objectForKey(NAME_KEY) as? String {
//                cell.textLabel?.text = name
//            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath.section == GROUP_TABLE_VIEW_SECTION {
            
            // Selected a Group
            
            var selectedGroup = self.mgdGroups[indexPath.row]
            
            var groupView = GroupTableViewController(group: selectedGroup)
            
            self.navigationController!.pushViewController(groupView, animated: true)
        }
        
        else if indexPath.section == CONVO_TABLE_VIEW_SECTION {
            
            // Seleted a Convo
            
//            var convo = self.mgdConvos[indexPath.row] as! Convo
//            println("Convo was selected: \(convo)")
//            var convoView = BlurbTableViewController(convo: convo)
            
//            self.navigationController?.pushViewController(convoView, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return TABLE_HEADER_HEIGHT
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
        var activityWidth = self.groupActivityIndicator.frame.width
        var activityFrame = CGRectMake(view.frame.width - activityWidth - 14, 0, activityWidth, view.frame.height)
        
        if section == GROUP_TABLE_VIEW_SECTION && self.mgdGroups.count > 0 {
            var label = UILabel(frame: CGRectMake(0, 0, tableView.frame.size.width, TABLE_HEADER_HEIGHT))
            label.text = "Groups"
            label.textAlignment = NSTextAlignment.Center
            view.addSubview(label)
            
            self.groupActivityIndicator.frame = activityFrame
            view.addSubview(self.groupActivityIndicator)
        }
        
        else if section == CONVO_TABLE_VIEW_SECTION && self.mgdConvos.count > 0 {
            
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
