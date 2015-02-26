//
//  Message.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Blurb: NSObject {

    
    var text: String?
    
    var user: String?
    
    var created: NSDate?
    
    var convoid: String?
    
    var currentUser = PFUser.currentUser().objectId
    //var currentConvo =
    
    lazy var blurbs = [Blurb]()
    
    
    // initialize a blurb
    init(text: String, user: String, created: NSDate, convoid: String?) {
        self.text = text
        self.user = user
        self.created = created
        self.convoid = convoid
        super.init()
    }
    
    init(networkObjectId: String) {
        super.init()
        
        //TODO: Create a query for convoids based on user
        
        
    }
    
    func saveToNetwork() {
        
        //TODO: Save the object created 
        
        var blurbObject = PFObject(className: "Blurb")
        blurbObject["text"] = self.text
        blurbObject["userId"] = currentUser
        blurbObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                NSLog("Saved blurb to the network")
            }
            else {
                NSLog("Failed to save blurb: %@", error.description)
            }
        }
    }
    
    func retrieveBlurb(convoid: String){
        
        var query = PFQuery(className: "Blurb")
        if let blurbObject = query.getObjectWithId(convoid) {
            
            NSLog("Successfully retrieved blurbs from the network")
            NSLog("Blurbs", blurbObject)
            self.text = blurbObject["text"] as? String
            self.user = blurbObject["userId"] as? String
            self.convoid = blurbObject["convoId"] as? String
            self.created = blurbObject.createdAt
        }
        else {
            NSLog("Failed to retrieve blurbs from the network")
        }
        
    }
    
}
