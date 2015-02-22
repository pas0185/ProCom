//
//  SDAFParseAPIClient.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class SDAFParseAPIClient: AFHTTPRequestOperationManager {
    
    class var sharedInstance: SDAFParseAPIClient {
        
        struct Static {
            static var instance: SDAFParseAPIClient?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SDAFParseAPIClient() as SDAFParseAPIClient
        }
        
        return Static.instance!
    }
}
