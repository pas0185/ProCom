//
//  SecondViewController.swift
//  To Do List
//
//  Created by Robert Monroe Irving Jr on 2/19/15.
//  Copyright (c) 2015 Robert Monroe Irving Jr. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtTask: UITextField!
    @IBOutlet var txtDesc: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Events
    @IBAction func btnAddTask_Click(sender: UIButton){
        taskMgr.addTask(txtTask.text, desc: txtDesc.text);
        self.view.endEditing(true)
        txtTask.text = ""
        txtDesc.text = ""
        self.tabBarController?.selectedIndex = 0;
        
    }
    
    // IOS Touch Funtions
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true)
        
    }
    
    
    // UITextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool{
        textField.resignFirstResponder();
        
        return true
    }

}

