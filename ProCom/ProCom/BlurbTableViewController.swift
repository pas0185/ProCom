//
//  BlurbTableViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class BlurbTableViewController: JSQMessagesViewController {
    
    var TEST_USER_ID = "KWX6vxRm6s"
    var TEST_CONVO_ID = "bVCfzNGIqt"
    
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
        
        

//        NSLog("Convo ID: %@", blurbconvoid!)
        
        let userQuery = PFQuery(className: "_User")
        
        userQuery.getObjectInBackgroundWithId(TEST_USER_ID, block:{(PFObject user, NSError error) in
            
            if (user != nil) {
                
                let queryConvo = PFQuery(className: "Convo")
                queryConvo.getObjectInBackgroundWithId(self.TEST_CONVO_ID, block: {(PFObject convo, NSError error) in
                
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
                                for a in array{
                                    if let b = a as? PFObject {
                                        if let blurbText = b.objectForKey("text") as? String
                                        {
                                            NSLog("text: %@", blurbText)
                                        }
                                        if let blurbSender = b.objectForKey("userId") as? PFObject
                                        {
                                            var username: String = blurbSender["username"] as String
//                                            let userNameQuery = PFQuery(className: "User")
//                                            userNameQuery.includeKey("username")

                                            NSLog("user: %@", username)
                                        }
//                                        
//                                        let blurb = Blurb(text: blurbText, sender: blurbSender, convoid: convoid)
//                                        self.messages.append(blurb)
//                                        self.finishReceivingMessage()
                                        
                                    }
                                }
                                
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
    
    
    // TODO: Send a query to post to a value on the database
    func sendMessage(text: String!, sender: String!, convoid: String!){
        var blurb = PFObject(className: "Blurb")
        blurb["text"] = text
        blurb["userId"] = user?.objectId
        blurb["convoId"] = TEST_CONVO_ID
        blurb.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                // The object has been saved.
            } else {
                // There was a problem, check error.description
            }
        }
    }
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        sendMessage(text, sender: sender, convoid: TEST_CONVO_ID)
        
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return blurbs[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let blurb = blurbs[indexPath.item]
        
        if blurb.sender() == sender {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blurbs.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let blurb = blurbs[indexPath.item]
        if blurb.sender() == sender {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        //        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor,
        //            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let blurb = blurbs[indexPath.item];
        
        // Sent by me, skip
        if blurb.sender() == sender {
            return nil;
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousblurb = blurbs[indexPath.item - 1];
            if previousblurb.sender() == blurb.sender() {
                return nil;
            }
        }
        
        return NSAttributedString(string:blurb.sender())
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let blurb = blurbs[indexPath.item]
        
        // Sent by me, skip
        if blurb.sender() == sender {
            return CGFloat(0.0);
        }
        
        // Same as previous sender, skip
        if indexPath.item > 0 {
            let previousblurb = blurbs[indexPath.item - 1];
            if previousblurb.sender() == blurb.sender() {
                return CGFloat(0.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }


    
}
