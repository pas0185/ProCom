//
//  Group.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Group: PFObject, PFSubclassing {
    
    var subGroups: [Group] = []
    var subConvos: [Convo] = []
    
    var name: String?
    var parentId: String?
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override init() {
        super.init()
    }
    
    init(name: String) {
        self.name = name
        super.init()
    }
    
    // initialize a new Convo, given an appropriate title
    init(name: String, parentId: String) {
        self.name = name
        self.parentId = parentId
        super.init()
    }
    
    init(networkObjectId: String) {
        super.init()
        
        var query = PFQuery(className: "Group")
        if let groupObject = query.getObjectWithId(networkObjectId) {
        
//        query.getObjectInBackgroundWithId(networkObjectId) {
//            (groupObject: PFObject!, error: NSError!) -> Void in
//            if error == nil {
                NSLog("Successfully retrieved group from the network")
                
                self.name = groupObject["name"] as? String
                self.objectId = groupObject.objectId
                self.parentId = groupObject["parentId"] as? String
                let subGroups = groupObject["subGroups"] as [String]
                
//                for subGroupId in subGroups {
//                    let subGroup = Group(networkObjectId: subGroupId)
//                    self.subGroups.append(subGroup)
//                }
            }
            else {
                NSLog("Failed to retrieve group from the network")
            }
        
    }
    
    class func parseClassName() -> String! {
        return "Group"
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
}
