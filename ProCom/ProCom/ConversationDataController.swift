//
//  ConversationDataController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class ConversationDataController: NSObject {
    
    var conversationList: [Conversation] =
        [
            Conversation(conversationTitle = "Meetings"),
            Conversation(conversationTitle = "Ideas"),
            Conversation(conversationTitle = "Suggestions")
        ]
}
