//
//  Message.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Blurb: PFObject, JSQMessageData {

    class func parseClassName() -> String! {
        return "Blurb"
    }
    
    var message: String = ""
    var username: String = ""
//    var createdAt: NSDate?
    //    var imagePathURL: String = ""
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override init() {
        super.init()
    }

    init(message: String, username: String, date: NSDate?, imageUrl: String?, convoID: PFObject) {
        super.init()
        
        self.message = message
        self.username = username
        
        
//        self["createdAt"] = date
//        self.imageUrl = imageUrl!
        
//        self.setObject(convoID, forKey: CONVO_ID) = convoID!
//        self.setObject(self.sender(), forKey: "username")
//        self[USERNAME] = sender!
//        self[TEXT] = text!
    }
    
    func text() -> String! {
        return self[TEXT] as String
//        return self.message
    }
    
    func sender() -> String! {
        return self[USERNAME] as String
//        return self.username
    }
    
    func date() -> NSDate! {
        return self["createdAt"] as NSDate
    }
    
//    func imageUrl() -> String? {
//        return self.imagePathURL
//    }
    
}