//
//  UserHandlingViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 3/6/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit
import ParseUI


class UserHandlingViewController: PFLogInViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate  {

    var window: UIWindow?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (PFUser.currentUser() == nil)
        {
            println("Current user not signed in yet, present PFLogInViewController")
            
            
            
            // Configure Login View Controller
//            var logInController = PFLogInViewController()
//            logInController.delegate = self /* UserHandlingViewController */
//            
//            self.logInView.backgroundColor = UIColor.darkGrayColor()
//
//            var loginDismissButton = logInView.dismissButton
//            loginDismissButton.removeFromSuperview()
//            var logInButton = logInView.logInButton
//            
//            // Present Login View Controller
//            self.navigationController?.presentViewController(logInController, animated:true, completion: nil)

            
//            if (logInButton.touchInside)
//            {
//                println("Login button tapped")
//                var groupView = GroupTableViewController(group: nil)
//                self.navigationController?.pushViewController(groupView, animated: true)
//            }
            
            // Configure Sign Up view
//            var signUpController = PFSignUpViewController()
//            signUpController.delegate = self
//            self.signUpController.view.backgroundColor = UIColor.darkGrayColor()
            
            
//            self.fields = (PFLogInFields.UsernameAndPassword
//                | PFLogInFields.LogInButton
//                | PFLogInFields.SignUpButton
//                | PFLogInFields.PasswordForgotten
//                | PFLogInFields.Facebook)
            
            
        }
        else
        {
            println("Current user is signed in, push group table view")
            
            self.dismissViewControllerAnimated(true, completion: nil)
            var groupView = GroupTableViewController(group: nil)
            self.navigationController?.pushViewController(groupView, animated: true)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PFLogInViewControllerDelegate
    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
        
        println("Should begin login with username, password. Will return true")
        return true
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        println("logInViewController did log in user, dismiss this VC")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
