//
//  UserAccessViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 4/22/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit
import ParseUI

class UserAccessViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (PFUser.currentUser() == nil) {
            // User is not signed in yet, display Log In View
            var logInViewController:PFLogInViewController = PFLogInViewController()
            logInViewController.delegate = self
            
            var dismissButton = logInViewController.logInView.dismissButton
            //        dismissButton.enabled = false
            var fbButton = logInViewController.logInView.facebookButton
            //        fbButton.enabled = true

            
            self.navigationController?.presentViewController(logInViewController, animated:true, completion: nil)
        }
        else {
            // User is already signed in. Push the Group View
            var gtView = GroupTableViewController(group: nil)
            self.navigationController?.setViewControllers([gtView], animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Facebook Setup
    
    func loginWithFacebook(){
        let permisions = ["user_about_me"]
        PFFacebookUtils.logInWithPermissions(permisions, block: {
            (user, error) -> Void in
            if (user != nil) {
                println("Uh oh. The user cancelled the Facebook login.")
            } else if (user!.isNew) {
                println("User signed up and logged in through Facebook!")
            } else {
                println("User logged in through Facebook!")
            }
        }
    )
    }
    
    func loadData(){
        if let session = PFFacebookUtils.session() {
            if session.isOpen {
                println("session is open")
                FBRequestConnection.startForMeWithCompletionHandler({ (connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                     println("done me request")
                if let dict = result as? Dictionary<String, AnyObject>{
                    let name:String = dict["name"] as AnyObject? as! String
                    let facebookID:String = dict["id"] as AnyObject? as! String
                    let email:String = dict["email"] as AnyObject? as! String
                    let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1"
                    var URLRequest = NSURL(string: pictureURL)
                    var URLRequestNeeded = NSURLRequest(URL: URLRequest!)
                    
                    NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!, error: NSError!) -> Void in
                        if error == nil {
                            println("DATA FOR IMAGE: \(data)")
                            var picture = PFFile(data: data)
                            PFUser.currentUser()!.setObject(picture, forKey: "profilePicture")
                            PFUser.currentUser()!.save()
                        }
                        else {
                            println("Error: \(error.localizedDescription)")
                        }
                        })
                        PFUser.currentUser()!.setValue(name, forKey: "username")
                        PFUser.currentUser()!.setValue(email, forKey: "email")
                        PFUser.currentUser()!.save()
                    }
                }
                )
            }
        }
    }
    
    // MARK: - PFLogInViewControllerDelegate
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        
        println("Should begin login with username, password. Will return true")
        return true
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        println("logInViewController did log in user, dismiss this VC")
        
        logInController.dismissViewControllerAnimated(true, completion: nil)
        
        var gtView = GroupTableViewController(group: nil)
        self.navigationController?.setViewControllers([gtView], animated: true)
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
        
        if self.navigationController?.presentedViewController != nil {
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        var gtView = GroupTableViewController(group: nil)
        self.navigationController?.setViewControllers([gtView], animated: true)
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didFailToSignUpWithError error: NSError!) {
        println("Failed to sign up user \(error.localizedDescription)")
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
