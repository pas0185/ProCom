//
//  CoreDataManager.swift
//  ProCom
//
//  Created by Patrick Sheehan on 4/20/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

private let _CoreDataManagerInstance = CoreDataManager()

class CoreDataManager: NSObject {

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext

    class var sharedInstance: CoreDataManager {
        return _CoreDataManagerInstance
    }
    
    //MARK: - Convos
    func fetchConvos(forGroup group: ManagedGroup?, completion: (convos: [ManagedConvo]) -> Void) {
        // Return all Convos saved in Core Data
        
        var convos = [ManagedConvo]()
        
        var fetchRequest = NSFetchRequest(entityName: "Convo")
        if let groupId = group?.pfId {
            println("Convo predicate from core: parent group ID = \(groupId)")
            fetchRequest.predicate  = NSPredicate(format: "parentGroupId == %@", groupId)
        }
        var error: NSError?
        
        // Send fetch request
        convos = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as! [ManagedConvo]
        
        if error != nil {
            println(error!.localizedDescription)
        }
        
        // Notify the fetch is finished to the completion block
        completion(convos: convos)
    }
    
    func saveNewConvo(name: String, pfId: String, parentGroupId: String) {
        
        if let entity = NSEntityDescription.entityForName("Convo", inManagedObjectContext: self.managedObjectContext!) {

            var mgdConvo = ManagedConvo(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
            
            mgdConvo.name = name
            mgdConvo.pfId = pfId
            mgdConvo.parentGroupId = parentGroupId
            
            var error: NSError?
            self.managedObjectContext?.save(&error)
            
            if error != nil {
                println("Error saving Convo to Core Data: \(error?.localizedDescription)")
            }
        }
    }
    
    //MARK: - Group
    func fetchGroups(forGroup group: ManagedGroup?, completion: (groups: [ManagedGroup]) -> Void) {
        // Return all Groups saved in Core Data
        
        var groups = [ManagedGroup]()
        
        var fetchRequest = NSFetchRequest(entityName: "Group")
        if let groupId = group?.pfId {
            println("Group predicate from core: parent group ID = \(groupId)")
            fetchRequest.predicate  = NSPredicate(format: "parentGroupId == %@", groupId)
        }
        var error: NSError?
        
        // Send fetch request
        groups = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as! [ManagedGroup]
        
        if error != nil {
            println(error!.localizedDescription)
        }
        
        // Notify the fetch is finished to the completion block
        completion(groups: groups)
    }
    
    func saveNewGroup(name: String, pfId: String, parentGroupId: String) {
        
        if let entity = NSEntityDescription.entityForName("Group", inManagedObjectContext: self.managedObjectContext!) {
            
            var mgdGroup = ManagedConvo(entity: entity, insertIntoManagedObjectContext: self.managedObjectContext)
            
            mgdGroup.name = name
            mgdGroup.pfId = pfId
            mgdGroup.parentGroupId = parentGroupId
            
            var error: NSError?
            self.managedObjectContext?.save(&error)
            
            if error != nil {
                println("Error saving Group to Core Data: \(error?.localizedDescription)")
            }
        }
    }
}
