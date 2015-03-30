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
        
        self[TEXT] = message
        self[USERNAME] = username
        self[CONVO_ID] = convoID
        self[USER_ID] = PFUser.currentUser()
    }
    
    func text() -> String! {
        return self[TEXT] as String
    }
    
    func sender() -> String! {
        return self[USERNAME] as String
    }
    
    func date() -> NSDate! {
        return self["createdAt"] as NSDate
    }
    
//    func imageUrl() -> String? {
//        return self.imagePathURL
//    }
    
}