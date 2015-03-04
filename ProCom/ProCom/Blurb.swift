//
//  Message.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Blurb: NSObject, JSQMessageData {

    
    var text_: String
    var sender_: String
    var date_: String
    
    var currentUser = PFUser.currentUser().objectId
    
    
    lazy var blurbs = [Blurb]()
    
    
    init(text: String?, sender: String?, date: String?) {
        text_ = text!
        sender_ = sender!
        date_ = date!
    }
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }
    
    func date() -> String! {
        return date_;
    }
        
}