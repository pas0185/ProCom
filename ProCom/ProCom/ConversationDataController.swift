//
//  ConversationDataController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class ConversationDataController: NSObject {
    
    lazy var conversationList = [Conversation]()
    
    override init() {
        super.init()
        
        addDummyData()
    }
    
    func addDummyData() {
        var c1 = Conversation(title: "Ideas")
        var c2 = Conversation(title: "Meetings")
        var c3 = Conversation(title: "Suggestions")
    }
}
