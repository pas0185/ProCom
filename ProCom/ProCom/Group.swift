//
//  Group.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Group: NSObject {
    
    // The name of this Group
    // ex: "iOS projects", "Finances"
    var title: String?

    // The sub categories within this Group
    // "lazy var" because we won't create this array in memory until needed
    // ex: think common file directory structure
    lazy var childGroupArray = [Group]()
    
    // The Convos stored in this Group
    // Convos are actual conversations containing text, users, pictures, etc
    lazy var convoArray = [Convo]()
    
    // The users that are subscribed to this Group
    // This variable is constant because Group always need to 
    // maintain a list of users, even if there aren't any
    let buddyArray = [Buddy]()

    // TODO: a Group might like to know it's "lineage" that can be displayed to the user, like a file path
    // ex: Abraid/iOS/ProCom/...
}
