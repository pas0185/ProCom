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
    var name: String?

    // The sub categories within this Group
    // "lazy var" because we won't create this array in memory until needed
    // ex: think common file directory structure
    lazy var childGroupArray = [Group]()
    
    // The Convos stored in this Group
    // Convos are actual conversations containing text, users, pictures, etc
    lazy var convoArray = [Convo]()
    
    // initialize a new Convo, given an appropriate title
    init(name: String) {
        self.name = name
    }
    
    // TODO: a Group might like to know it's "lineage" that can be displayed to the user, like a file path
    // ex: Abraid/iOS/ProCom/...
}
