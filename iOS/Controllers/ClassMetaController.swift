//
//  ClassMetaController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/24/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ClassMetaViewModel: BaseViewModel {
    lazy var classTitle: MutableProperty<String?> = {
        return MutableProperty<String?>(self.classroom?.title)
    }()
    lazy var classRoom: MutableProperty<String?> = {
        return MutableProperty<String?>(self.classroom?.room)
    }()
    lazy var classInstructor: MutableProperty<String?> = {
        return MutableProperty<String?>(self.classroom?.instructor)
    }()
    
    override func initialValues(classroom: Classroom) {
        self.classTitle.value = classroom.title
        self.classRoom.value = classroom.room
        self.classInstructor.value = classroom.instructor
    }
    
    override func setupBindings(classroom: Classroom) {
        DynamicProperty(object: classroom, keyPath: "title") <~ self.classTitle.producer.map { text in text as AnyObject? }
        DynamicProperty(object: classroom, keyPath: "room") <~ self.classRoom.producer.map { text in text as AnyObject? }
        DynamicProperty(object: classroom, keyPath: "instructor") <~ self.classInstructor.producer.map { text in text as AnyObject? }
    }
}

class ClassMetaController: UITableViewController {
    let viewModel: ClassMetaViewModel = {
        return ClassMetaViewModel()
    }()
    var classroom: Classroom? {
        get {
            return self.viewModel.classroom
        }
        set(newClassroom) {
            self.viewModel.classroom = newClassroom
        }
    }
    
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
            let cell = tableView.dequeueReusableCellWithIdentifier("MetaCell", forIndexPath: indexPath) as! ClassMetaInfoCell
            
            cell.classTitleLabel.text = self.viewModel.classTitle.value
            cell.classRoomLabel.text = self.viewModel.classRoom.value
            cell.classInstructorLabel.text = self.viewModel.classInstructor.value
            
            cell.classTitleLabel.placeholder = NSLocalizedString("ClassMetaController.title", comment: "Title Placeholder")
            cell.classRoomLabel.placeholder = NSLocalizedString("ClassMetaController.room", comment: "Room Placeholder")
            cell.classInstructorLabel.placeholder = NSLocalizedString("ClassMetaController.instructor", comment: "Insturctor Placeholder")
            
            self.viewModel.classTitle <~ cell.rac_classTitleLabelSignal
            self.viewModel.classRoom <~ cell.rac_classRoomLabelSignal
            self.viewModel.classInstructor <~ cell.rac_classInstructorLabelSignal
            
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

class ClassMetaInfoCell: UITableViewCell {
    @IBOutlet weak var classTitleLabel: UITextField!
    @IBOutlet weak var classRoomLabel: UITextField!
    @IBOutlet weak var classInstructorLabel: UITextField!
    
    var rac_classTitleLabelSignal: SignalProducer<String?, NoError> {
        let signal = classTitleLabel.rac_textSignal()
            .toSignalProducer()
            .map { text in
                return text as? String
            }
            .takeUntil(rac_prepareForReuseProducer)
            .flatMapError({ _ in return SignalProducer<String?, NoError>.empty })
        
        return signal
    }
    
    var rac_classRoomLabelSignal: SignalProducer<String?, NoError> {
        return classRoomLabel.rac_textSignal()
            .toSignalProducer()
            .map { text in
                return text as? String
            }
            .takeUntil(rac_prepareForReuseProducer)
            .flatMapError({ _ in return SignalProducer<String?, NoError>.empty })
    }
    
    var rac_classInstructorLabelSignal: SignalProducer<String?, NoError> {
        return classInstructorLabel.rac_textSignal()
            .toSignalProducer()
            .map { text in
                return text as? String
            }
            .takeUntil(rac_prepareForReuseProducer)
            .flatMapError({ _ in return SignalProducer<String?, NoError>.empty })
    }
    
    @IBAction func classTitleEndExit(sender: AnyObject) {
        self.classRoomLabel.becomeFirstResponder()
    }
    @IBAction func classRoomEndExit(sender: AnyObject) {
        self.classInstructorLabel.becomeFirstResponder()
    }
    @IBAction func classInstructorEndExit(sender: AnyObject) {
        self.classInstructorLabel.resignFirstResponder()
    }
}
