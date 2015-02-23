//
//  Message.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/14/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

/*class Blurb: PFObject(className: "Blurb") {

    
    Blurb
    
    let id : NSString?
    let convoid : NSString?
    let created : NSString?
    let userid : NSString?
    var text : NSString?
    
    init(text: String) {
        self.text = text
    }
}

    */

var Blurb = PFObject(className: "Blurb")
let blurbtext = Blurb["text"] as String
let blurbcreatedat = Blurb.createdAt


