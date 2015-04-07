//
//  AppDelegate.swift
//  ProCom
//
//  Created by Abraid on 2/12/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit
import CoreData
import ParseUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {

    var window: UIWindow?
    var navController: UINavigationController?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Parse setup
        Group.registerSubclass()
        Convo.registerSubclass()
        Blurb.registerSubclass()
        Parse.enableLocalDatastore()
        Parse.setApplicationId("n3twpTW37Eh9SkLFRWM41bjmw2IoYPdb2dh3OAQC", clientKey: "TG5IOJyDtOkkijqBt3BXlSa1gKtxUm7k2dXBYxuF")
        
        // Push notifications
        self.setupPushNotifications(application)
        
        // Configure main view
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.makeKeyAndVisible()

        self.navController = UINavigationController()
        self.window?.rootViewController = navController
        
        var replyAction : UIMutableUserNotificationAction = UIMutableUserNotificationAction()
        replyAction.identifier = "REPLY_ACTION"
        replyAction.title = "Yes, I need!"
        
        replyAction.activationMode = UIUserNotificationActivationMode.Foreground
        replyAction.authenticationRequired = false


        println("LAUNCH OPTIONS: \(launchOptions)")
        
        if (PFUser.currentUser() == nil) {
            
            var logInController = PFLogInViewController()
            logInController.delegate = self
            
            var signUpController = PFSignUpViewController()
            signUpController.delegate = self
            logInController.signUpController = signUpController
            
//            logInController.signUpController.delegate = self
            
            self.navController?.presentViewController(logInController, animated: true, completion: nil)
        }
        else {
            self.navController?.pushViewController(GroupTableViewController(group: nil), animated: true)
        }

        
        return true
    }
    
    // MARK: - PFLogInViewControllerDelegate
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        
        println("Should begin login with username, password. Will return true")
        return true
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        println("logInViewController did log in user, dismiss this VC")
        logInController.dismissViewControllerAnimated(true, completion: nil)
        
        // TODO: smoother transition to this on login
        self.navController?.pushViewController(GroupTableViewController(group: nil), animated: true)
    }
    
    func logInViewController(logInController: PFLogInViewController!, didFailToLogInWithError error: NSError!) {
        
        println("Failed to log in user: \(error.localizedDescription)")
    }
    
    // MARK: - PFSignUpViewControllerDelegate
    func signUpViewController(signUpController: PFSignUpViewController!, shouldBeginSignUp info: [NSObject : AnyObject]!) -> Bool {
        println("Should beging signup")
        return true
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        
        println("Did sign up user")
        
        signUpController.dismissViewControllerAnimated(true, completion: nil)
        
        if self.navController?.presentedViewController != nil {
            self.navController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        self.navController?.pushViewController(GroupTableViewController(group: nil), animated: true)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up user \(error.localizedDescription)")
    }
    
    // MARK: - Push Notifications
    func setupPushNotifications(application: UIApplication) {
        
        // Register for Push Notitications
    
        if NSProcessInfo().isOperatingSystemAtLeastVersion(NSOperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0)) {
            println("iOS >= 8.0.0")
            let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        }
        else {
            println("iOS < 8.0.0")
            application.registerForRemoteNotificationTypes(.Alert | .Badge | .Sound)
        }
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        // Register to receive notifications
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        println("didRegisterForRemoteNotificationsWithDeviceToken")
        
        let currentInstallation = PFInstallation.currentInstallation()
        
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackgroundWithBlock { (succeeded, e) -> Void in
            
            println("Successfully registered for remote notifications with device token")
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        println("failed to register for remote notifications:  \(error)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        println("didReceiveRemoteNotification in app delegate")
        
        println("User Info: \(userInfo)")
        if let convo: AnyObject = userInfo["convoObject"] {
            println("Convo from push notification = \(convo)")
        
            var convoQuery = Convo.query()
            if let actualConvo = convoQuery.getObjectWithId(convo as String) as? Convo {
                // You got it?
                println("\(actualConvo)")
                var blurbViewControlerr = BlurbTableViewController(convo: actualConvo)
                self.navController?.pushViewController(blurbViewControlerr, animated: true)
                return
            }
        
        }
        
        
        if let viewController = self.navController?.topViewController as? BlurbTableViewController {
            println("Top view is blurb table view. Need to refresh for new message from push notification")
            viewController.didReceiveRemoteNotification(userInfo)
        }
        
        if let senderObjectId = userInfo["senderObjectId"] as? String {
            
            if PFUser.currentUser().objectId == senderObjectId {
                // Don't do the notification thing
                println("Remote notification received from the user that sent it (in AppDelegate)")
            }
            else {
                println("Received remote notification in AppDelegate from a different user")
                PFPush.handlePush(userInfo)
            }
        }

    }
    
    func signInUser(username: String, password: String, synchronous: Bool) {
        
        // Synchronous
        if synchronous {
            var user = PFUser.logInWithUsername(username, password: password)
            if (user != nil) {
                println("Successfully logged in \(username)")
            }
            else {
                println("Failed to log in \(username)")
            }
        }
            
        // Asynchronous
        else {
            PFUser.logInWithUsernameInBackground(username, password: password) {
                (user: PFUser!, error: NSError!) -> Void in
                if (user != nil) {
                    println("Successfully logged in \(username)")
                }
                else {
                    println("Failed to log in \(username)")
                }
            }
        }
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: NSString?, annotation: AnyObject) -> Bool {
        
        var wasHandled:Bool = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        return wasHandled
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
     
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.abraid.ProCom" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("ProCom", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ProCom.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

