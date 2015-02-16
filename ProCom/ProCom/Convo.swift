//
//  Convo.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Convo: NSObject {
    
    // The name of this Convo
    // ex: "Suggestions", "OSHA Project"
    var title: String?
    
    // The Blurbs (messages) that comprise this conversation
    let blurbArray = [Blurb]()
    
    // The Buddies (users) that are subscribed to this Convo
    let buddyArray = [Buddy]()
    
    // initialize a new Convo, given an appropriate title
    init(title: String) {
        self.title = title
    }
}
