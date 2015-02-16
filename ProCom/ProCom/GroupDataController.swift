//
//  ConvoDataController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class ConvoDataController: NSObject {
    
    lazy var convoList = [Convo]()
    
    override init() {
        super.init()
        
        addDummyData()
    }
    
    func addDummyData() {
        var c1 = Convo(title: "Ideas")
        var c2 = Convo(title: "Meetings")
        var c3 = Convo(title: "Suggestions")
    }
}
