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
    
//    blurbconvoid = "wuxLc8VgGz"
    var user: PFUser? // PFUser.currentUser().objectId
    var blurbs = [Blurb]()
    var refreshTime = NSTimer()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor(red: 148/255, green: 34/255, blue: 50/255.0, alpha: 1))
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.grayColor())
  
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyScrollsToMostRecentMessage = true
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
                        queryBlurb.includeKey("createdAt")
                        
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
                                        var message: String
                                        var user: String
                                        var date: NSDate
                                        if let blurbText = b.objectForKey("text") as? String
                                        {
                                            NSLog("text: %@", blurbText)
                                            message = blurbText
                                            if let blurbSender = b.objectForKey("userId") as? PFObject
                                            {
                                                var username: String = blurbSender["username"] as String
                                                NSLog("user: %@", username)
                                                user = username
                                                
                                                var blurbDate = b.createdAt
                                                NSLog("date: %@", blurbDate)
                                                date = blurbDate
                                                    
                                                var blurb = Blurb(text: message, sender: user, date: date, imageUrl: nil)
                                                self.blurbs.append(blurb)
                                                self.finishReceivingMessage()                                            }
                                        }
                                    }
                                }
                                
                                NSLog("blurbs %@", array)
                                
                                //blurbs for this convo
                                self.collectionView.reloadData()
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
    
    
//    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
//        if let stringUrl = imageUrl {
//            if let url = NSURL(string: stringUrl) {
//                if let data = NSData(contentsOfURL: url) {
//                    let image = UIImage(data: data)
//                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
//                    let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
//                    avatars[name] = avatarImage
//                    return
//                }
//            }
//        }
//        
//        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
//        setupAvatarColor(name, incoming: incoming)
//    }
//    
//    func setupAvatarColor(name: String, incoming: Bool) {
//        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
//        
//        let rgbValue = name.hash
//        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
//        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
//        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
//        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
//        
//        let nameLength = countElements(name)
//        let initials : String? = name.substringToIndex(advance(sender.startIndex, min(3, nameLength)))
//        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
//        
//        avatars[name] = userImage
//    }
    
    
    // TODO: Send a query to post to a value on the database
    func sendMessage(text: String!, sender: String!, convoid: String!){
        var blurb = PFObject(className: "Blurb")
        blurb["text"] = text
        blurb["userId"] = self.TEST_USER_ID
        blurb["convoId"] = TEST_CONVO_ID
        blurb.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                NSLog("Blurb: %@", blurb)
            } else {
                NSLog("There was a problem sending the message")
            }
        }
    }
    
    func receivedMessagePressed(sender: UIBarButtonItem) {
        // Simulate reciving message
        showTypingIndicator = !showTypingIndicator
        scrollToBottomAnimated(true)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        println("Camera pressed!")
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, sender: String!, date: NSDate!) {

        JSQSystemSoundPlayer.jsq_playMessageSentSound()
//        sendMessage(text, sender: PFUser.currentUser().objectId, convoid: TEST_CONVO_ID)
        sendMessage(text, sender: self.TEST_USER_ID, convoid: TEST_CONVO_ID)
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return blurbs[indexPath.item] as JSQMessageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let blurb = blurbs[indexPath.item]
        
        if blurb.sender() == sender {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        
        return nil
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.blurbs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let blurb = self.blurbs[indexPath.item]
        if blurb.sender() == sender {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
//        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor, NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle]
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
