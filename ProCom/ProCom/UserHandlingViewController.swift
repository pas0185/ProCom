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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (PFUser.currentUser().isAuthenticated() == false)
        {
            var logInViewController:PFLogInViewController = PFLogInViewController()
            logInViewController.delegate = self
            self.presentViewController(logInViewController, animated:true, completion: nil)
            logInViewController.title = "ProCom"

        }
        if (PFUser.currentUser().isAuthenticated())
        {
            self.presentViewController(GroupTableViewController(), animated: true, completion: nil)
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
