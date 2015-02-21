//
//  SignUpViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/18/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController{
    
    

       
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var messageLabel: UILabel!
    
    @IBAction func loginVerifyButton(sender: AnyObject) {
        var usrEntered = usernameTextField.text
        var pwdEntered = passwordTextField.text
        var emlEntered = emailTextField.text
        var conEntered = passwordTextField.text
        
        func userSignUp() {
            var user = PFUser()
            user.username = usrEntered
            user.password = pwdEntered
            user.email = emlEntered
            user.save()
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool!, error: NSError!) -> Void in
                if error == nil {
                    self.messageLabel.text = "Sign Up Success!";
                } else {
                    // Show the errorString somewhere and let the user try again.
                }
            }
        }
        
        if usrEntered != "" && pwdEntered != "" && emlEntered != "" && pwdEntered == conEntered {
            userSignUp()
        } else {
            self.messageLabel.text = "All Fields Required"
        }
        
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
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
