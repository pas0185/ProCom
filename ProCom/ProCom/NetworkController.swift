//
//  NetworkController.swift
//  ProCom
//
//  Created by Patrick Sheehan on 4/20/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

private let _NetworkControllerInstance = NetworkController()

class NetworkController: NSObject {
    
    class var sharedInstance: NetworkController {
        return _NetworkControllerInstance
    }
    
    func fetchNewConvos(forGroup group: ManagedGroup?, convos: [ManagedConvo], completion: (newConvos: [Convo]) -> Void) {
        
        var convos = [Convo]()
        
//        completion()
//        completion(newConvos: convos)
    }
}
