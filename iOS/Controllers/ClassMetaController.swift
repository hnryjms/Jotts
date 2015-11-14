//
//  ClassMetaController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/24/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ClassMetaController: UITableViewController {
    var classroom: Classroom?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.tableView.backgroundColor = nil
        } else {
            self.navigationItem.rightBarButtonItem = nil
            
            /*
            NSNotificationCenter.defaultCenter().rac_notifications(UIKeyboardWillHideNotification, object: nil)
                .startWithNext { [unowned self] notification in
                    let insets = UIEdgeInsets(top: self.tableView.contentInset.top,
                        left: self.tableView.contentInset.left,
                        bottom: 0,
                        right: self.tableView.contentInset.right);
                    
                    self.tableView.contentInset = insets;
                    self.tableView.scrollIndicatorInsets = insets;
                }
            
            NSNotificationCenter.defaultCenter().rac_notifications(UIKeyboardWillChangeFrameNotification, object: nil)
                .startWithNext { [unowned self] notification in
                    let size = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size;
                    let insets = UIEdgeInsets(top: self.tableView.contentInset.top,
                        left: self.tableView.contentInset.left,
                        bottom: size.height,
                        right: self.tableView.contentInset.right);
                    
                    self.tableView.contentInset = insets;
                    self.tableView.scrollIndicatorInsets = insets;
                }
            */
        }
    }
    
    // MARK: - Table data source & delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.classroom == nil {
            return 0
        }
        
        return 3
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1:
            guard let schedule = self.classroom!.schedule else { return 1 }
            return schedule.count + 1
        case 2:
            guard let sessions = self.classroom!.sessions else { return 1 }
            return sessions.count + 1
        default: abort()
        }
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 120
        default: return 44
        }
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("MetaCell", forIndexPath: indexPath)
            
            return cell
        case 1:
            if self.classroom!.schedule != nil && indexPath.row < self.classroom!.schedule!.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("ScheduleCell", forIndexPath: indexPath)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddScheduleCell", forIndexPath: indexPath)
                
                return cell
            }
        case 2:
            if self.classroom!.sessions != nil && indexPath.row < self.classroom!.sessions!.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("SessionCell", forIndexPath: indexPath)
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("AddSessionCell", forIndexPath: indexPath)
                
                return cell
            }
        default: abort()
        }
    }
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        switch indexPath.section {
        case 1:
            guard let schedule = self.classroom!.schedule else { return false }
            return indexPath.row < schedule.count;
        case 2:
            guard let sessions = self.classroom!.sessions else { return false }
            return indexPath.row < sessions.count;
        default: return false
        }
    }
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
