//
//  BlurbTableViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class BlurbTableViewController: JSQMessagesViewController {
    
    var mgdBlurbs = [ManagedBlurb]()
    var convo: ManagedConvo?
    
//    var user: PFUser?
    var blurbs: [Blurb] = []
//    var convo: Convo?
    
    
    
    var refreshControl:UIRefreshControl!
    var lastMessageTime: NSDate?
    var notificationTime = NSDate()
    
    var refreshTime = NSTimer()
    var avatars = Dictionary<String, UIImage>()
    var outgoingBubbleImageView = JSQMessagesBubbleImageFactory.outgoingMessageBubbleImageViewWithColor(UIColor(red: 148/255, green: 34/255, blue: 50/255.0, alpha: 1))
    var incomingBubbleImageView = JSQMessagesBubbleImageFactory.incomingMessageBubbleImageViewWithColor(UIColor.grayColor())
    
    init(convo: ManagedConvo) {
        super.init(nibName: nil, bundle: nil)
        
        self.convo = convo
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK: - Loading Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sender = PFUser.currentUser().username!
       
        self.automaticallyScrollsToMostRecentMessage = true
        collectionView.collectionViewLayout.springinessEnabled = true

        
        //refreshing the blurbs
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Getting Blurbs!")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        //Added a settings button to navbar
        var settingsImage = UIImage(named: "settingsicon.png")
        var settingButton: UIBarButtonItem = UIBarButtonItem(image: settingsImage, style: .Plain, target: self, action: "settingsButtonClicked")
        self.navigationItem.rightBarButtonItem = settingButton
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.fetchBlurbs()
    }
    
    func didReceiveRemoteNotification(userInfo: [NSObject: AnyObject]) {
        self.fetchBlurbs()
    }
    
    //MARK: - User Controls
    
    func refresh(sender:AnyObject)
    {
        println("refresh called")
        self.collectionView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func settingsButtonClicked(){
        // TODO: fix settings page configuration
//        var settingsPage = ConvoSettingsViewController(convo: convo!)
//        self.navigationController!.pushViewController(settingsPage, animated: true)
    }
    
    //MARK: - Blurb handling
    
    func fetchBlurbs() {
        
        if let convoId = self.convo?.pfId {
            
            // CoreData fetching blurbs
            CoreDataManager.sharedInstance.fetchBlurbs(convoId, completion: {
                (blurbs) -> Void in
                
                println("Fetched \(blurbs.count) Blurbs from Core Data")
                self.mgdBlurbs = blurbs
                
                // Networking fetching Blurbs
                NetworkManager.sharedInstance.fetchNewBlurbs(convoId, user: PFUser.currentUser(), completion: {
                    (blurbs: [Blurb]) in
                    
                    // Received new Blurbs from the network
                    println("BlurbTableView received \(blurbs.count) new Blurbs from Network")
                    
                    // Save new Blurbs to Core Data
                    CoreDataManager.sharedInstance.saveNewBlurbs(blurbs, completion: {
                        (newMgdBlurbs: [ManagedBlurb]) -> Void in
                        
                        println("Finished saving \(newMgdBlurbs.count) new Blurbs to Core Data. Now adding to TableView")
                        
                        // Add new *converted* Convos to the TableView Data Source
                        self.mgdBlurbs.extend(newMgdBlurbs)
                        
                        self.finishReceivingMessage()
                        self.collectionView.reloadData()
                        
                    })
                })
            })
              
        }
    }
    
    func sendMessage(text: String) {
        
        if let convoId = self.convo?.pfId,
            user = PFUser.currentUser() {
        
            // Create a Blurb
            var blurb = Blurb()
            blurb["convoId"] = convoId
            blurb["text"] = text
            blurb["userId"] = user
            
                
            NetworkManager.sharedInstance.saveNewBlurb(blurb, completion: {
                (blurb) -> Void in
                self.finishSendingMessage()
                self.collectionView.reloadData()


                println("Notifying other members that new message was sent")
                self.pushNotifyOtherMembers(text)
            })
        }
    }
    
    func pushNotifyOtherMembers(message: String) {
        
        if let c = self.convo {
            
            if let channel = c.getChannelName() {
                let data = [
                    "content-available" : 1,
                    "badge" : "Increment",
                    "alert" : PFUser.currentUser().username + " in " + c.name + " says: " + message,
                    "senderObjectId" : PFUser.currentUser().objectId,
                    "convoObject" : c.pfId,
                    "sound": "default"
                    ]
                
                println("Sending PFPush for new message: \(message)")
                
                let push = PFPush()
                push.setChannel(channel)
                push.setData(data as [NSObject : AnyObject])
                push.sendPushInBackgroundWithBlock {
                    (success: Bool, error: NSError!) -> Void in
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
        else {
            println("Failed to push notify other members, Convo object not found for this view")
        }
    }

    //#MARK: - Setting up Blurbs
    
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
            setupAvatarImage(message.sender(), imageUrl: nil /*message.imageUrl()*/, incoming: true)
            return UIImageView(image:avatars[message.sender()])
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.blurbs.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let blurb = self.blurbs[indexPath.row]
        if blurb.sender() as NSString == PFUser.currentUser().username {
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
        if blurb.sender() == PFUser.currentUser().username {
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
            if blurb.sender() == PFUser.currentUser().username {
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
