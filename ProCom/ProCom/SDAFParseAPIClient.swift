//
//  SDAFParseAPIClient.swift
//  ProCom
//
//  Created by Patrick Sheehan on 2/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

class SDAFParseAPIClient: AFHTTPRequestOperationManager {
    
    class var sharedInstance: SDAFParseAPIClient {
        
        struct Static {
            static let kSDFParseAPIBaseURLString = "https://api.parse.com/1/"
            
            static let kSDFParseAPIApplicationId = "n3twpTW37Eh9SkLFRWM41bjmw2IoYPdb2dh3OAQC"
            static let kSDFParseAPIKey = "IoJbgCApWyrOwn4MyMEk6XIV5TLpxhqwHq7PsESw"
            
            static var instance: SDAFParseAPIClient?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SDAFParseAPIClient(baseURL: NSURL(string: Static.kSDFParseAPIBaseURLString))
        }
        
        return Static.instance!
    }
}
