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
    
    var convoid_: String
    
    var currentUser = PFUser.currentUser().objectId
    
    
    lazy var blurbs = [Blurb]()
    
    
    init(text: String?, sender: String?, convoid: String?, date: NSDate?) {
        text_ = text!
        sender_ = sender!
        convoid_ = convoid!
        date_ = date!
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
    
//    func saveToNetwork() {
//        
//        //TODO: Save the object created 
//        
//        var blurbObject = PFObject(className: "Blurb")
//        blurbObject["text"] = self.text_
//        blurbObject["userId"] = currentUser
//        blurbObject["convoId"] = convoid
//        blurbObject.saveInBackgroundWithBlock {
//            (success: Bool, error: NSError!) -> Void in
//            if (success) {
//                NSLog("Saved blurb to the network")
//            }
//            else {
//                NSLog("Failed to save blurb: %@", error.description)
//            }
//        }
//    }
    
}