//
//  NetworkController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 4/20/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

private let _NetworkControllerInstance = NetworkController()

class NetworkController: NSObject {
    
    class var sharedInstance: NetworkController {
        return _NetworkControllerInstance
    }
    
    func fetchNewConvos(forGroup group: ManagedGroup?, existingConvos: [ManagedConvo], user: PFUser, completion: (newConvos: [Convo]) -> Void) {
        
        var convos = [Convo]()
        
        // Build Convo Query...
        let convoQuery = Convo.query()
        
        // For all that the user belongs to...
        convoQuery.whereKey(USERS_KEY, equalTo: user)
        
        // ...That we don't have yet
        var existingConvoIds: [String] = []
        for convo in existingConvos {
            existingConvoIds.append(convo.pfId)
        }
        println("Existing Convo IDs being excluded from query: \(existingConvoIds)")
        convoQuery.whereKey(OBJECT_ID_KEY, notContainedIn: existingConvoIds)
        
        
        if let groupId = group?.pfId {
            println("Convo predicate from Network: parent group ID = \(groupId)")
            convoQuery.whereKey("parentGroupId", equalTo: groupId)
        
            // Send the Convo query
            convoQuery.findObjectsInBackgroundWithBlock({
                (objects: [AnyObject]!, error: NSError!) -> Void in
                
                if (error == nil) {
                    println("Fetched \(objects.count) convos from Network")
                    
                    convos = objects as! [Convo]
                    completion(newConvos: convos)
                }
            })
        }
        else {
            println("Could not perform Convo Network fetch for empty groupId")
        }
    }
    
    func saveNewGroup(group: Group, completionHandler: (group: Group) -> Void) {

        group.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                println("Successfully saved new group: \(group)")
                completionHandler(group: group)
            }
            else {
                println("Failed to save new group: \(group)")
            }
        }
    }
    
    func fetchNewGroups(groupId: String, existingGroupIds: [String], completion: (newGroups: [Group]) -> Void) {
        
        var groups = [Group]()
        
        // Build Group Query...
        let groupQuery = Group.query()
        groupQuery.whereKey("parentGroupId", equalTo: groupId)
        groupQuery.whereKey(OBJECT_ID_KEY, notContainedIn: existingGroupIds)
        
        // Send the query
        groupQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if (error == nil) {
                println("Fetched \(objects.count) new Groups from Network")
                
                groups = objects as! [Group]
                completion(newGroups: groups)
            }
        })
    }
}
