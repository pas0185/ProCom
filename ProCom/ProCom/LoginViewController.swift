//
//  LoginViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/18/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit
import ParseUI

class LoginViewController: UIViewController, FBLoginViewDelegate, PFLogInViewControllerDelegate{

    //@IBOutlet var fbLoginView : FBLoginView!
    @IBOutlet weak var loginUser: UITextField!
    @IBOutlet weak var loginPass: UITextField!

    @IBAction func login(sender: AnyObject) {
        if ((PFUser.logInWithUsername(loginUser.text, password: loginPass.text)) != nil){
            var user = PFUser.currentUser()
            user.save()
            self.performSegueWithIdentifier("showGroup", sender: self)
            PFUser.logInWithUsernameInBackground(loginUser.text, password: loginPass.text, block: nil)
        }
        
    }
    
    /*func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) -> Void
    {
        FBRequestConnection.startForMeWithCompletionHandler({connection, result, error in
            if (true)
            {
                PFUser.currentUser().setObject("User", forKey: "objectId")
                PFUser.currentUser().save()
            }
            else
            {
                println("Error")
            }
        })
    }*/

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Facebook Integration
        /*self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
        println("User: \(loginUser.text)")*/
        
        
         
        var query = PFQuery(className: "User")
        query.whereKey("username", equalTo: loginUser.text)
        query.whereKey("password", equalTo: loginPass.text)
        

        // Do any additional setup after loading the view.
    }
    
    /* -----Facebook Integration
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
        println("This is where you perform a segue.")
        self.performSegueWithIdentifier("showGroup", sender: LoginViewController())
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser){
        println("User Name: \(user.name)")
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
    }*/

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
