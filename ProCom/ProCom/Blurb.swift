//
//  Message.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Blurb: NSObject, JSQMessageData {

    
    var text_: String
    var sender_: String
    var date_: NSDate
    var imageUrl_: String?
    
    var created: NSDate?
    
    var convoid: String?
    
    var currentUser = PFUser.currentUser().username
    //var currentConvo =
    
    lazy var blurbs = [Blurb]()
    
    
    init(text: String?, sender: String?, imageUrl: String?, date: NSDate?, convoid: String?) {
        self.text_ = text!
        self.sender_ = currentUser
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
        self.convoid = convoid
    }
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }
    
    func date() -> NSDate! {
        return date_;
    }
    
    func imageUrl() -> String? {
        return imageUrl_;
    }
    
    func saveToNetwork() {
        
        //TODO: Save the object created 
        
        var blurbObject = PFObject(className: "Blurb")
        blurbObject["text"] = self.text_
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
            self.text_ = blurbObject["text"] as String
            self.sender_ = blurbObject["userId"] as String
            self.convoid = blurbObject["convoId"] as? String
            self.created = blurbObject.createdAt
        }
        else {
            NSLog("Failed to retrieve blurbs from the network")
        }
        
    }
    
}

class Message : NSObject, JSQMessageData {
    var text_: String
    var sender_: String
    var date_: NSDate
    var imageUrl_: String?
    
    convenience init(text: String?, sender: String?) {
        self.init(text: text, sender: sender, imageUrl: nil)
    }
    
    init(text: String?, sender: String?, imageUrl: String?) {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
    }
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }
    
    func date() -> NSDate! {
        return date_;
    }
    
    func imageUrl() -> String? {
        return imageUrl_;
    }
}
