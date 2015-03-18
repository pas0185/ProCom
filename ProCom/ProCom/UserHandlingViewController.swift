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
            var logInViewController:PFLogInViewController = PFLogInViewController()
            logInViewController.delegate = self
            
            var signUpViewController:PFSignUpViewController = PFSignUpViewController()
            signUpController.delegate = self
            
            self.presentViewController(logInViewController, animated: true, completion: nil)
        }
        else
        {
            var groupview = GroupTableViewController(group: nil)
            self.presentViewController(groupview, animated: true, completion: nil)
        }
        
    }
    
    
    
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
