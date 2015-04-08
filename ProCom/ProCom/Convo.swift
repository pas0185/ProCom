//
//  Convo.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

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
        
        convo.setValue(self[NAME_KEY], forKey: NAME_KEY)
        convo.setValue(self.objectId, forKey: OBJECT_ID_KEY)
        
        //        group.setValue( ... createdAt
        //        group.setValue( ... group
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
    }
}


