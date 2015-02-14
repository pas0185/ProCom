//
//  Conversation.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Conversation: NSObject {
    
    var title: String = ""
    
    var messageArray = [Message]()
    
    init(title: String) {
        self.title = title
    }
}
