//
//  ClassMetaController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/24/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import enum Result.NoError

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
    lazy var tintColor: MutableProperty<UIColor?> = {
        return MutableProperty<UIColor?>(UIColor(fromHex: self.classroom?.color))
    }()
    
    override func initialValues(_ classroom: Classroom) {
        self.classTitle.value = classroom.title
        self.classRoom.value = classroom.room
        self.classInstructor.value = classroom.instructor
    }
    
    override func setupBindings(_ classroom: Classroom) {
        BindingTarget(lifetime: self.reactive.lifetime, action: { classroom.title = $0 }) <~ self.classTitle.producer
        BindingTarget(lifetime: self.reactive.lifetime, action: { classroom.room = $0 }) <~ self.classRoom.producer
        BindingTarget(lifetime: self.reactive.lifetime, action: { classroom.instructor = $0 }) <~ self.classInstructor.producer

        self.tintColor <~ classroom.rac_color.map { UIColor(fromHex: $0) }
    }

    func save() {
        do {
            try self.classroom?.validate()
            self.core.save()
        } catch {
            print("Skipping validation error")
        }
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
    override var traitCollection: UITraitCollection {
        return UIApplication.shared.delegate!.window!!.traitCollection
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.topNavigationController!.navigationBar.reactive.makeBindingTarget { $0.tintColor = $1 } as BindingTarget<UIColor?> <~ self.viewModel.tintColor.producer
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.horizontalSizeClass == .regular {
            self.topNavigationController!.navigationBar.barStyle = .default
            self.topNavigationController!.navigationBar.barTintColor = nil
            self.tableView.backgroundColor = nil
            if #available(iOS 11, *) {
                self.topNavigationController!.navigationBar.prefersLargeTitles = false
            }
        } else {
            self.topNavigationController!.navigationBar.barStyle = .blackOpaque
            self.topNavigationController!.navigationBar.barTintColor = UIColor.darkGray
            self.tableView.backgroundColor = UIColor.darkGray
            if #available(iOS 11, *) {
                self.topNavigationController!.navigationBar.prefersLargeTitles = true
            }
        }
    }

    deinit {
        self.viewModel.save()
    }
    
    // MARK: - Table data source & delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.classroom == nil {
            return 0
        }
        
        return 3
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return 120
        default: return 44
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MetaCell", for: indexPath) as! ClassMetaInfoCell
            
            cell.classTitleLabel.text = self.viewModel.classTitle.value
            cell.classRoomLabel.text = self.viewModel.classRoom.value
            cell.classInstructorLabel.text = self.viewModel.classInstructor.value
            
            cell.classTitleLabel.placeholder = NSLocalizedString("ClassMetaController.title", comment: "Title Placeholder")
            cell.classRoomLabel.placeholder = NSLocalizedString("ClassMetaController.room", comment: "Room Placeholder")
            cell.classInstructorLabel.placeholder = NSLocalizedString("ClassMetaController.instructor", comment: "Instructor Placeholder")

            self.viewModel.classTitle <~ cell.rac_classTitleLabelSignal
            self.viewModel.classRoom <~ cell.rac_classRoomLabelSignal
            self.viewModel.classInstructor <~ cell.rac_classInstructorLabelSignal
            
            return cell
        case 1:
            if self.classroom!.schedule != nil && indexPath.row < self.classroom!.schedule!.count {
                let schedule = self.classroom!.schedule![indexPath.row] as! Schedule
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! ClassMetaTextCell

                cell.classTextLabel.reactive.text <~ schedule.rac_details

                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath) as! ClassMetaTextCell

                cell.classTextLabel.text = NSLocalizedString("ClassMetaController.addSchedule", comment: "Add Schedule Button")
                
                return cell
            }
        case 2:
            if self.classroom!.sessions != nil && indexPath.row < self.classroom!.sessions!.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! ClassMetaTextCell
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath) as! ClassMetaTextCell

                cell.classTextLabel.text = NSLocalizedString("ClassMetaController.addSession", comment: "Add Session Button")

                return cell
            }
        default: abort()
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
}

class ClassMetaInfoCell: UITableViewCell {
    @IBOutlet weak var classTitleLabel: UITextField!
    @IBOutlet weak var classRoomLabel: UITextField!
    @IBOutlet weak var classInstructorLabel: UITextField!
    
    var rac_classTitleLabelSignal: Signal<String?, NoError> {
        return classTitleLabel.reactive.textValues
            .take(until: self.reactive.prepareForReuse)
    }

    var rac_classRoomLabelSignal: Signal<String?, NoError> {
        return classRoomLabel.reactive.textValues
            .take(until: self.reactive.prepareForReuse)
    }
    
    var rac_classInstructorLabelSignal: Signal<String?, NoError> {
        return classInstructorLabel.reactive.textValues
            .take(until: self.reactive.prepareForReuse)
    }
    
    @IBAction func classTitleEndExit(_ sender: AnyObject) {
        self.classRoomLabel.becomeFirstResponder()
    }
    @IBAction func classRoomEndExit(_ sender: AnyObject) {
        self.classInstructorLabel.becomeFirstResponder()
    }
    @IBAction func classInstructorEndExit(_ sender: AnyObject) {
        self.classInstructorLabel.resignFirstResponder()
    }
}

class ClassMetaTextCell: UITableViewCell {
    @IBOutlet weak var classTextLabel: UILabel!
}
