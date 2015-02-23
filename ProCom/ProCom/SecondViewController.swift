//
//  SecondViewController.swift
//  To Do List
//
//  Created by Robert Monroe Irving Jr on 2/19/15.
//  Copyright (c) 2015 Robert Monroe Irving Jr. All rights reserved.
//

import UIKit
import EventKit

class SecondViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtTask: UITextField!
    @IBOutlet var txtDesc: UITextField!

    
        // Add to calendar
    @IBAction func btnCalandar(sender: UIButton){
        var eventStore : EKEventStore = EKEventStore()
        // 'EKEntityTypeReminder' or 'EKEntityTypeEvent'
        eventStore.requestAccessToEntityType(EKEntityTypeEvent, completion: {
            granted, error in
            if (granted) && (error == nil) {
                println("granted \(granted)")
                println("error  \(error)")
                
                var event:EKEvent = EKEvent(eventStore: eventStore)
                event.title = "Test Title"
                event.startDate = NSDate()
                event.endDate = NSDate()
                event.notes = "This is a note"
                event.calendar = eventStore.defaultCalendarForNewEvents
                eventStore.saveEvent(event, span: EKSpanThisEvent, error: nil)
                println("Saved Event")
            }
        })
        
        
        // This lists every reminder
        var predicate = eventStore.predicateForRemindersInCalendars([])
        eventStore.fetchRemindersMatchingPredicate(predicate) { reminders in
            for reminder in reminders {
                println(reminder.title)
            }}
        
        
        // What about Calendar entries?
        var startDate=NSDate().dateByAddingTimeInterval(-60*60*24)
        var endDate=NSDate().dateByAddingTimeInterval(60*60*24*3)
        var predicate2 = eventStore.predicateForEventsWithStartDate(startDate, endDate: endDate, calendars: nil)
        
        println("startDate:\(startDate) endDate:\(endDate)")
        var eV = eventStore.eventsMatchingPredicate(predicate2) as [EKEvent]!
        
        if eV != nil {
            for i in eV {
                println("Title  \(i.title)" )
                println("stareDate: \(i.startDate)" )
                println("endDate: \(i.endDate)" )
                
                if i.title == "Test Title" {
                    println("YES" )
                    // Uncomment if you want to delete
                    //eventStore.removeEvent(i, span: EKSpanThisEvent, error: nil)
                }
            }
        }
        
        
    }
    
    
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

