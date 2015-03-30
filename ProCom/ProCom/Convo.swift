//
//  Convo.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Convo: PFObject, PFSubclassing {
    
    class func parseClassName() -> String! {
        return CONVO_CLASS
    }
    
    override init() {
        super.init()
    }
    
    func getChannelName() -> String! {
        
        let objectId = self.objectId
        var channel = "channel" + objectId
        return channel
    }
}


