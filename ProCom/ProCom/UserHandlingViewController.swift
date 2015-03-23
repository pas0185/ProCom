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
            var logInController = PFLogInViewController()
            logInController.delegate = self
            logInController.fields = (PFLogInFields.UsernameAndPassword
                | PFLogInFields.LogInButton
                | PFLogInFields.SignUpButton
                | PFLogInFields.PasswordForgotten
                | PFLogInFields.Facebook)
            var loginDismissButton = logInView.dismissButton
            loginDismissButton.removeFromSuperview()
            self.navigationController?.presentViewController(logInController, animated:true, completion: nil)
        }
        else
        {
            var groupView = GroupTableViewController(group: nil)
            self.navigationController?.pushViewController(groupView, animated: true)
        }
        
    }
    
    
//    func logInViewController(logInController: PFLogInViewController!, shouldBeginLogInWithUsername username: String!, password: String!) -> Bool {
//        if (username.isEmpty && password.isEmpty) {
//            
//            
//            var alert = UIAlertView()
//            alert.title = "Missing Informatiom"
//            alert.message = "Fill in all information"
//            alert.delegate = nil
//            return false
//        }
//        else
//        {
//            return true // Begin login process
//        }
//        
//    }
    

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
