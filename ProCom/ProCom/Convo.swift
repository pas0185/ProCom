//
//  Convo.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Convo: PFObject, PFSubclassing {
    
    class func parseClassName() -> String! {
        return CONVO_CLASS
    }
    
    override init() {
        super.init()
    }
    
    func getChannelName() -> String! {
        
        let objectId = self.objectId
        var channel = "channel" + objectId
        return channel
    }
    
    func saveToCore() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let entity = NSEntityDescription.entityForName("Convo", inManagedObjectContext: managedContext)
        
        let convo = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        convo.setValue(self.objectId, forKey: OBJECT_ID_KEY)
        convo.setValue(self[NAME_KEY], forKey: NAME_KEY)
        convo.setValue(self[CREATED_AT_KEY], forKey: CREATED_AT_KEY)
//        convo.setValue(self[GROUP_KEY], forKey: GROUP_KEY)

        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
    
    class func convosFromNSManagedObjects(objects: [NSManagedObject]) -> [Convo] {
        
        var convos: [Convo] = []
        
        for obj in objects {
            var convo = Convo()
//            convo.setValue(obj.valueForKey(OBJECT_ID_KEY), forKey: OBJECT_ID_KEY)
            convo.setValue(obj.valueForKey(NAME_KEY), forKey: NAME_KEY)
            convo.setValue(obj.valueForKey(CREATED_AT_KEY), forKey: CREATED_AT_KEY)

            // TODO: parent group
            // TODO: users
            
            convos.append(convo)
        }
        
        return convos
    }
}


