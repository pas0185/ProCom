//
//  BlurbTableViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class BlurbTableViewController: JSQMessagesViewController {
    

    
//    var blurbconvoid: PFRelation
//    blurbconvoid = "wuxLc8VgGz"
    var user: PFUser? // PFUser.currentUser().objectId
    var blurbs = [Blurb]()
    var refreshTime = NSTimer()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleBlueColor())
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    
//    @IBOutlet var blurbField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        user = PFUser.currentUser()
        
        var TEST_USER_ID = "KWX6vxRm6s"
        var TEST_CONVO_ID = "wuxLc8VgGz"

//        NSLog("Convo ID: %@", blurbconvoid!)
        
        let userQuery = PFQuery(className: "_User")
        
        userQuery.getObjectInBackgroundWithId(TEST_USER_ID, block:{(PFObject user, NSError error) in
            
            if (user != nil) {
                
                let queryConvo = PFQuery(className: "Convo")
                queryConvo.getObjectInBackgroundWithId(TEST_CONVO_ID, block: {(PFObject convo, NSError error) in
                
                    if (convo != nil) {
                        NSLog("Convo %@", convo)
                        let queryBlurb = PFQuery(className: "Blurb")
                        queryBlurb.includeKey("userId")
                        queryBlurb.whereKey("convoId", equalTo: convo)
                        queryBlurb.orderByAscending("createdAt")
                    
                        //Sending off query
                        queryBlurb.findObjectsInBackgroundWithBlock({(NSArray array, NSError error) in
                            if (error != nil) {
                                NSLog("error " + error.localizedDescription)
                            }
                            else {
                                
                                NSLog("blurbs %@", array)
                                
                                //blurbs for this convo
                                self.blurbs = array as [Blurb]
                            }
                        })
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
