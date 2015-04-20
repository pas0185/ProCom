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
    
    func fetchConvos(forGroup group: Group?, completion: (convos: [ManagedConvo]) -> Void) {
        // Return all Convos saved in Core Data
        
        var convos = [ManagedConvo]()
        
        var fetchRequest = NSFetchRequest(entityName: "Convo")
        var error: NSError?
        
        // Send fetch request
        convos = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as! [ManagedConvo]
        
        if error != nil {
            println(error!.localizedDescription)
        }
        
        // Notify the fetch is finished to the completion block
        completion(convos: convos)
    }
    
    func fetchGroups(forGroup group: Group?, completion: (groups: [ManagedGroup]) -> Void) {
        // Return all Groups saved in Core Data
        
        var groups = [ManagedGroup]()
        
        var fetchRequest = NSFetchRequest(entityName: "Group")
        var error: NSError?
        
        // Send fetch request
        groups = managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as! [ManagedGroup]
        
        if error != nil {
            println(error!.localizedDescription)
        }
        
        // Notify the fetch is finished to the completion block
        completion(groups: groups)
    }
}
