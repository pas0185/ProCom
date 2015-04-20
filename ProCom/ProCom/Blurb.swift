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
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override init() {
        super.init()
    }

    init(message: String, user: PFUser, convo: Convo) {
        super.init()

        self[TEXT] = message
        self[USERNAME] = user.username
        self[CONVO_ID] = convo
        self[USER_ID] = user
    }

    func text() -> String! {
        return self[TEXT] as! String
    }
    
    func sender() -> String! {
        return self[USERNAME] as! String
    }
    
    func date() -> NSDate! {
        return self["createdAt"] as! NSDate
    }
    
    func userAvatar() -> NSData!{
        if let currentUser = self[USER_ID] as? PFUser{
            currentUser.fetchIfNeeded()
            if let profilePifc = currentUser["profilePicture"] as! NSData?{
                return profilePifc
            }
            return nil
        }
        return nil
    }
    
    func imageUrl() -> NSData? {
//        var profilePic = PFQuery().getObjectWithId(PFUser.currentUser().objectId)
//        profilePic.
//        profilePic.whereKey("profilePicture", equalTo: NSData()) as UIImage
//        return profilePic
        return nil
    }
    
}