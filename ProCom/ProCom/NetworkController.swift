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
        convoQuery.whereKey(OBJECT_ID_KEY, notContainedIn: existingConvoIds)
        
        // Send the query
        convoQuery.findObjectsInBackgroundWithBlock({
            (objects: [AnyObject]!, error: NSError!) -> Void in
            
            if (error == nil) {
                println("Fetched \(objects.count) convos from Network")
                
                convos = objects as! [Convo]
                completion(newConvos: convos)
            }
        })
    }
}
