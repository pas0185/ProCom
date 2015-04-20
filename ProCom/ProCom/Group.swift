//
//  Group.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit
import CoreData

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
    
    func getSubGroups() -> [Group] {
        
        var query = Group.query()
        query.fromLocalDatastore()
        
        query.whereKey(PARENT_GROUP_KEY, equalTo: self)
        var subGroups: [Group] = query.findObjects() as! [Group]
        println("\(subGroups.count) groups in the selected group")
        
        return subGroups
    }
    
    func getSubConvos() -> [Convo] {
        
        var query = Convo.query()
        query.fromLocalDatastore()
        
        query.whereKey(GROUP_KEY, equalTo: self)
        var subConvos: [Convo] = query.findObjects() as! [Convo]
        println("\(subConvos.count) convos in the selected group")
        
        
        return subConvos
    }
}
