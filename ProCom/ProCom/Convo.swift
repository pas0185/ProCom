//
//  Convo.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Convo: NSObject {
    
    // instance variables for the Convo
    var title: String = ""
    let blurbArray = [Blurb]()
    
    // initialize a new Convo, given an appropriate title
    init(title: String) {
        self.title = title
    }
    
    // add a new Blurb to this conversation
    func addBlurb(b: Blurb) {
        
        self.messageArray.append(b)
    }
}
