//
//  Message.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class Blurb: PFObject, JSQMessageData {

    class func parseClassName() -> String! {
        return "Blurb"
    }
    
    var text_: String
    var sender_: String
    var date_: NSDate
    var imageUrl_: String?
    
    lazy var blurbs = [Blurb]()
    
    
    
    init(text: String?, sender: String?, date: NSDate?, imageUrl: String?) {
        text_ = text!
        sender_ = sender!
        date_ = date!
        
        super.init()
    }
    
    func text() -> String! {
        return text_;
    }
    
    func sender() -> String! {
        return sender_;
    }
    
    func date() -> NSDate! {
        return date_;
    }
    
    func imageUrl() -> String? {
        return imageUrl_;
    }
    
}