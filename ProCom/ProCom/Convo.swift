//
//  Convo.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Convo: NSObject {
    
    // The user-friendly code used to join this conversation
    var incode: Int?
    
    // Time the conversation was created
    var createdat: NSDate?
    
    // Time of the conversation's most recent message
    var updatedat: NSDate?
    
    // Title of this conversation
    var title: String?
    
    // The admin of this conversation; can add/remove users
    var moderator: User?
    
    // The Blurbs (messages) that make up this conversation
    let blurbArray = [Blurb]()
    
    // The users that are subscribed to this Convo
    let members = [User]()
    
    // initialize a new Convo, given an appropriate title
    init(title: String) {
        self.title = title
    }
}
