//
//  LoginViewController.swift
//  ProCom
//
//  Created by Meshach Joshua on 2/18/15.
//  Copyright (c) 2015 Abraid. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, FBLoginViewDelegate  {

    @IBOutlet var fbLoginView : FBLoginView!
    @IBOutlet weak var loginUser: UITextField!
    @IBOutlet weak var loginPass: UITextField!

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "email", "user_friends"]
         
        var query = PFQuery(className: "User")
        query.whereKey("username", equalTo: loginUser)
        

        // Do any additional setup after loading the view.
    }
    
    func loginViewShowingLoggedInUser(loginView : FBLoginView!) {
        println("User Logged In")
        println("This is where you perform a segue.")
    }
    
    func loginViewFetchedUserInfo(loginView : FBLoginView!, user: FBGraphUser){
        println("User Name: \(user.name)")
    }
    
    func loginViewShowingLoggedOutUser(loginView : FBLoginView!) {
        println("User Logged Out")
    }
    
    func loginView(loginView : FBLoginView!, handleError:NSError) {
        println("Error: \(handleError.localizedDescription)")
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
