//
//  BlurbTableViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class BlurbTableViewController: JSQMessagesViewController {
    
    var user: PFUser?
    var blurbs: [Blurb] = []
    var convo: Convo?
    
    var refreshTime = NSTimer()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor(red: 148/255, green: 34/255, blue: 50/255.0, alpha: 1))
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.grayColor())
    
    
    init(convo: Convo) {
        super.init()
        self.convo = convo
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let c = convo as Convo? {
            self.fetchBlurbsForConvo(c)
        }
        
        // Add an 'add user' button to navbar
        var addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addUserButtonClicked")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    func addUserButtonClicked() {
        
        println("Add user button clicked")
        
        let alert = UIAlertController(title: "Add User to this Convo", message: "Enter your buddy's username", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler:{ (alertAction:UIAlertAction!) in
            let textField = alert.textFields![0] as UITextField
            let username = textField.text
            println(username)
            
            if let convoId = self.convo?.objectId as String? {
                
                self.addUserToConvo(username, convoId: convoId)
            }
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func addUserToConvo(username: String, convoId: String) {
        
    }
    
    func fetchBlurbsForConvo(convo: Convo) {
        
        automaticallyScrollsToMostRecentMessage = true
        
        var user = PFUser.currentUser()
    
        if (user != nil) {
    
            let queryBlurb = PFQuery(className: "Blurb")
            queryBlurb.includeKey("userId")
            queryBlurb.includeKey("createdAt")
            
            queryBlurb.whereKey("convoId", equalTo: convo)
            queryBlurb.orderByAscending("createdAt")
            
            //Sending off query
            queryBlurb.findObjectsInBackgroundWithBlock({(NSArray array, NSError error) in
                
                if (error == nil) {
                    
                    for a in array {
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
                                    self.finishReceivingMessage()
                                }
                            }
                        }
                    }
                    
                    NSLog("blurbs %@", array)
                    
                    //blurbs for this convo
                    self.collectionView.reloadData()
                }
            })
        }
    }
    
    func setupAvatarImage(name: String, imageUrl: String?, incoming: Bool) {
        if let stringUrl = imageUrl {
            if let url = NSURL(string: stringUrl) {
                if let data = NSData(contentsOfURL: url) {
                    let image = UIImage(data: data)
                    let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                    let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
                    avatars[name] = avatarImage
                    return
                }
            }
        }
        
        // At some point, we failed at getting the image (probably broken URL), so default to avatarColor
        setupAvatarColor(name, incoming: incoming)
    }
    
    func setupAvatarColor(name: String, incoming: Bool) {
        let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
        
        let rgbValue = name.hash
        let r = CGFloat(Float((rgbValue & 0xFF0000) >> 16)/255.0)
        let g = CGFloat(Float((rgbValue & 0xFF00) >> 8)/255.0)
        let b = CGFloat(Float(rgbValue & 0xFF)/255.0)
        let color = UIColor(red: r, green: g, blue: b, alpha: 0.5)
        
        let nameLength = countElements(name)
        let initials : String? = name.substringToIndex(advance(sender.startIndex, min(3, nameLength)))
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
    }
    
    func sendMessage(text: String!, sender: String!, convo: Convo){
        
        // TODO: fix Blurb's parameters and class members
        var blurb = Blurb(text: text, sender: sender, date: NSDate(), imageUrl: nil)
        blurb[CONVO_ID] = convo
        blurb[USER_ID] = PFUser.currentUser()
        blurb[USERNAME] = PFUser.currentUser()!.username
        blurb[TEXT] = text
        blurb.sender_ = PFUser.currentUser()!.username
        
        blurb.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if (success) {
                NSLog("Blurb: %@", blurb)
                self.blurbs.append(blurb)
                self.finishReceivingMessage()
                self.collectionView.reloadData()
                
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
        sendMessage(text, sender: PFUser.currentUser().objectId, convo: self.convo!)
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
        
        let message = blurbs[indexPath.item]
        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {
            setupAvatarImage(message.sender(), imageUrl: message.imageUrl(), incoming: true)
            return UIImageView(image:avatars[message.sender()])
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.blurbs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell
        
        let blurb = self.blurbs[indexPath.row]
        if blurb.sender() == PFUser.currentUser() {
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
        let blurb = blurbs[indexPath.row];
        
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
