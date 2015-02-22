//
//  Group.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Group: NSObject {
    
    // The name of this Group
    // ex: "iOS projects", "Finances"
    var name: String?

    var parentId: String?
    
    // The sub categories within this Group
    // "lazy var" because we won't create this array in memory until needed
    // ex: think common file directory structure
    lazy var childGroupArray = [Group]()
    
    // The Convos stored in this Group
    // Convos are actual conversations containing text, users, pictures, etc
    lazy var convoArray = [Convo]()
    
    // initialize a new Convo, given an appropriate title
    init(name: String, parentId: String) {
        self.name = name
        self.parentId = parentId
        super.init()
    }
    
    func retrieveFromNetwork(objectId: String) -> Group? {
        var query = PFQuery(className: "Group")
        query.getObjectInBackgroundWithId(objectId) {
            (groupObject: PFObject!, error: NSError!) -> Void in
            if error == nil {
                NSLog("Successfully retrieved group from the network")
                
                let name = groupObject["name"] as String
                let parentId = groupObject["parentId"] as String
                let subGroups = groupObject["subGroups"] as [String]
                
                let group = Group(name: name, parentId: parentId)
                for subGroupId in subGroups {
                    if let subGroup = self.retrieveFromNetwork(subGroupId) {
                        group.childGroupArray.append(subGroup)
                    }
                }
            }
            else {
                NSLog("Failed to retrieve group from the network: %@", error.description)
            }
        }
        
        return nil
    }
    func saveToNetwork() {
        
        var groupObject = PFObject(className: "Group")
        groupObject["name"] = self.name
        groupObject["parent"] = self.parentId
        groupObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                NSLog("Saved new group to the network")
            }
            else {
                NSLog("Failed to save new group: %@", error.description)
            }
        }
    }
    
    // TODO: a Group might like to know it's "lineage" that can be displayed to the user, like a file path
    // ex: Abraid/iOS/ProCom/...
}
