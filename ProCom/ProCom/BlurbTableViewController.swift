//
//  BlurbTableViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class BlurbTableViewController: JSQMessagesViewController {
    
    var blurbconvoid: String?
    var user = PFUser.currentUser().objectId
    var blurbs = [Blurb]()
    var refreshTime = NSTimer()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleBlueColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
    @IBOutlet var blurbField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSLog("Convo ID:", blurbconvoid!)
        
        let userQuery = PFQuery(className: "_User")
        
        userQuery.getObjectInBackgroundWithId(user, block:{(PFObject user, NSError error) in
            
            if (user != nil) {
                
                let queryBlurb = PFQuery(className: "Blurb")
                queryBlurb.whereKey("convoId", equalTo: self.blurbconvoid)
                queryBlurb.findObjectsInBackgroundWithBlock({(NSArray array, NSError error) in
                    if (error != nil) {
                        NSLog("error " + error.localizedDescription)
                    }
                    else {
                        NSLog("blurbs %@", array as [Blurb])
                        
                        //blurbs for this convo
                        self.blurbs = array as [Blurb]
                    }
                })
            }
        })


        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return blurbs[indexPath.item]
    }

    
}
