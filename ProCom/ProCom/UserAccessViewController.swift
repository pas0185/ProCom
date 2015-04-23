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
            let fbButton : FBSDKLoginButton = FBSDKLoginButton()
            // User is not signed in yet, display Log In View
            var logInViewController:PFLogInViewController = PFLogInViewController()
            logInViewController.fields = (PFLogInFields.Facebook | PFLogInFields.LogInButton | PFLogInFields.PasswordForgotten | PFLogInFields.UsernameAndPassword | PFLogInFields.SignUpButton)
            logInViewController.delegate = self
    
            if(logInViewController.logInView.facebookButton == nil)
            {
                let permissions = ["user_about_me"]
                PFFacebookUtils.logInWithPermissions(permissions) {
                    (user, error) in
                    if (user == nil) {
                        if (error == nil) {
                            println("User cancelled FB login")
                        }else{
                            println("FB login error: \(error)")
                        }
                    } else if user!.isNew {
                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                        var gtView = GroupTableViewController(group: nil)
                        self.navigationController?.setViewControllers([gtView], animated: true)
                        println("User signed up and logged in with Facebook")
                        
                        
                    } else {
                        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
                        var gtView = GroupTableViewController(group: nil)
                        self.navigationController?.setViewControllers([gtView], animated: true)
                        println("User logged in via Facebook")
                        
                    }
                }

            }
            
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
