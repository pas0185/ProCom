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
    var refreshControl:UIRefreshControl!
    var lastMessageTime: NSDate?
    var notificationTime = NSDate()
    
    var refreshTime = NSTimer()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor(red: 148/255, green: 34/255, blue: 50/255.0, alpha: 1))
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.grayColor())
    
    init(convo: Convo) {
        super.init(nibName: nil, bundle: nil)
        self.convo = convo
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //#MARK: - Loading Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sender = PFUser.currentUser()!.username!
       
        
        if let c = convo as Convo? {
            self.fetchBlurbsForConvo(c)
        }
        
        //refreshing the blurbs
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Getting Blurbs!")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        //Added a settings button to navbar
        var settingsImage = UIImage(named: "settingsicon.png")
        var settingButton: UIBarButtonItem = UIBarButtonItem(image: settingsImage, style: .Plain, target: self, action: "settingsButtonClicked")
        self.navigationItem.rightBarButtonItem = settingButton
        
        self.navigationItem.title = convo?.objectForKey(NAME_KEY) as! String?
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
    }
    
    //#MARK: - User Controls
    
    func refresh(sender:AnyObject)
    {
        println("refresh called")
        self.collectionView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func settingsButtonClicked(){
        var settingsPage = ConvoSettingsViewController(convo: convo!)
        self.navigationController!.pushViewController(settingsPage, animated: true)
    }
    
    //#MARK: - Blurb handling
    
    func fetchBlurbsForConvo(convo: Convo) {
        
        
        
        automaticallyScrollsToMostRecentMessage = true
        
        if (PFUser.currentUser() != nil) {
    
            let queryBlurb = Blurb.query()
            queryBlurb!.includeKey("userId")
            queryBlurb!.includeKey("createdAt")
            
            queryBlurb!.whereKey("convoId", equalTo: convo)
            
            if let myDate = lastMessageTime{
                queryBlurb!.whereKey("createdAt", greaterThan: myDate)
                println("Query for grabbing new objects was excecuted with this date: \(myDate)")
            }
            
            queryBlurb!.orderByAscending("createdAt")
            
            //TODO: Save in local core datastore
            
            
            // Fetch all blurbs for this convo
            queryBlurb!.findObjectsInBackgroundWithBlock({
                (array, error) in
                
                if (error == nil) {
                    println("blurb query fetched \(array!.count) objects")
                    
                    println("Pinnning blurb objects")
                    PFObject.pinAll(array)
                    println("Done pinning blurb objects")
                
                    var fetchedBlurbs = array as! [Blurb]
                    println("casted to blurbs count = \(fetchedBlurbs.count)")
                
                    self.handleTheseBlurbs(fetchedBlurbs)
                }
            })
        }
    }
    
    func handleTheseBlurbs(someBlurbs: [Blurb]) {
        println("I'm handling \(someBlurbs.count) blurbs")
        
        var localLastMessageTime: NSDate?
        
        for b in someBlurbs {
            //TODO: Compare for most recent message time
            //            if b.createdAt < lastMessageTime
            //            {
            //
            //            }
            self.blurbs.append(b)
        }
        
        
        
        lastMessageTime = someBlurbs.last?.createdAt
        println("The last message was \(lastMessageTime)")
        self.finishReceivingMessage()
        self.collectionView.reloadData()
    }
    
    func didReceiveRemoteNotification(userInfo: [NSObject: AnyObject]) {
        self.fetchBlurbsForConvo(self.convo!)
        self.finishReceivingMessage()
        self.collectionView.reloadData()
    }
    
    
    func sendMessage(text: String) {
        
        var blurb = Blurb(message: text, user: PFUser.currentUser()!, convo: self.convo!)
        
       blurb.saveInBackgroundWithBlock {
            (success, error) in
            if (success) {
                println("Blurb successfully saved: \(text)")
                self.finishSendingMessage()
                self.collectionView.reloadData()
                
                self.pushNotifyOtherMembers(text, currentConvo: self.convo?.objectForKey(NAME_KEY) as! String, username: PFUser.currentUser()!.username!)
                
            } else {
                println("There was a problem sending the message")
            }
        }
    }
    
    func pushNotifyOtherMembers(message: String, currentConvo: String, username: String) {
        let userId = PFUser.currentUser()?.objectId as String!
        if let channel = self.convo?.getChannelName() {
            let data = NSMutableDictionary()
            data.setObject(1, forKey: "content-available")
            data.setObject("Increment", forKey: "badge")
            data.setObject(username + " in " + currentConvo + " says: " + message, forKey: "alert")
            data.setObject(userId, forKey: "senderObjectId")
            data.setObject(self.convo!.objectId!, forKey: "convoObject")
            data.setObject("default", forKey: "sound")
//            
//            let data = [
//                "content-available" : 1,
//                "badge" : "Increment",
//                "alert" : username + " in " + currentConvo + " says: " + message,
//                "senderObjectId" : PFUser.currentUser()!.objectId,
//                "convoObject" : self.convo!.objectId,
//                "sound": "default"
//                ]
            
            println("\(blurbs.last?.objectId as String!)")
            
            let push = PFPush()
            push.setChannel(channel)
            push.setData(data as [NSObject : AnyObject])
            push.sendPushInBackgroundWithBlock {
                (success, error) in
                if (success) {
                    println("successfully notified other members")
                }
                else {
                    println("failed to send push notification to other members")
                }
            }
        }
        else {
            println("failed to send push notification to other members; failed to get channel name for convo")
        }
    }

    //#MARK: - Setting up Blurbs
    
    func setupAvatarImage(name: String, userPic: NSData, incoming: Bool) {
        if let data = userPic as NSData? {
            
                let image = UIImage(data: data)
                let diameter = incoming ? UInt(collectionView.collectionViewLayout.incomingAvatarViewSize.width) : UInt(collectionView.collectionViewLayout.outgoingAvatarViewSize.width)
                let avatarImage = JSQMessagesAvatarFactory.avatarWithImage(image, diameter: diameter)
                avatars[name] = avatarImage
                return
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
        
        let nameLength = count(name)
        let initials : String? = name.substringToIndex(advance(sender.startIndex, min(2, nameLength)))
        let userImage = JSQMessagesAvatarFactory.avatarWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(CGFloat(13)), diameter: diameter)
        
        avatars[name] = userImage
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
        self.sendMessage(text)
        finishSendingMessage()
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        
        return self.blurbs[indexPath.item] as JSQMessageData
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, bubbleImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        let blurb = blurbs[indexPath.item]
        
        if blurb[USER_ID] as! PFObject == PFUser.currentUser() {
            return UIImageView(image: outgoingBubbleImageView.image, highlightedImage: outgoingBubbleImageView.highlightedImage)
        }
        
        return UIImageView(image: incomingBubbleImageView.image, highlightedImage: incomingBubbleImageView.highlightedImage)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageViewForItemAtIndexPath indexPath: NSIndexPath!) -> UIImageView! {
        
        let message = blurbs[indexPath.item]
        if let avatar = avatars[message.sender()] {
            return UIImageView(image: avatar)
        } else {
            setupAvatarImage(message.sender(), userPic: message.userAvatar(), incoming: true)
            return UIImageView(image:avatars[message.sender()])
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.blurbs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let blurb = self.blurbs[indexPath.row]
        if blurb.sender() as NSString == PFUser.currentUser()!.username {
            cell.textView.textColor = UIColor.whiteColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        
        let attributes : [NSObject:AnyObject] = [NSForegroundColorAttributeName:cell.textView.textColor, NSUnderlineStyleAttributeName: 1]
        cell.textView.linkTextAttributes = attributes
        
        return cell
    }
    
    
    // View  usernames above bubbles
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let blurb = blurbs[indexPath.row];
        
        // Sent by me, skip
        if blurb.sender() == PFUser.currentUser()!.username {
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
    
    
    //Decideds where the blurb should be located ie. left or right side of the view
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {

        if let blurb = blurbs[indexPath.item] as Blurb? {
            
            // Sent by me, skip
            if blurb.sender() == PFUser.currentUser()!.username {
                return CGFloat(0.0);
            }
            
            // Same as previous sender, skip
            if indexPath.item > 0 {
                if let previousblurb = self.blurbs[indexPath.item - 1] as Blurb? {
                    if previousblurb.sender() == blurb.sender() {
                        return CGFloat(0.0);
                    }
                }
            }
        
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }


    
}
