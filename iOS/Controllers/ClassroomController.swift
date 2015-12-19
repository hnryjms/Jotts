//
//  ClassroomController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import ReactiveCocoa

class ClassroomViewModel: BaseViewModel {
    lazy var classTitle: MutableProperty<String?> = {
        return MutableProperty<String?>(self.classroom?.title)
    }()
    lazy var classDetails: MutableProperty<String?> = {
        return MutableProperty<String?>(self.classroom?.room)
    }()
    
    func save() {
        guard let classroom = self.classroom else {
            // There's no point in continuing if the state here was invalid.
            return
        }
        
        do {
            try classroom.validate()
        } catch {
            self.core.delete(classroom)
        }
        
        self.core.save()
    }
    
    override func initialValues(classroom: Classroom) {
        self.classTitle.value = classroom.title
    }
    
    override func setupBindings(classroom: Classroom) {
        self.classTitle <~ classroom.rac_title
        self.classDetails <~ classroom.rac_details.map { x in x as String? }
    }
}

class ClassroomController: UIViewController {
    let viewModel: ClassroomViewModel = {
        return ClassroomViewModel()
    }()
    var classroom: Classroom? {
        get {
            return self.viewModel.classroom
        }
        set(newClassroom) {
            self.viewModel.classroom = newClassroom
        }
    }
    
    @IBOutlet weak var classTitleLabel: UILabel!
    @IBOutlet weak var classDetailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DynamicProperty(object: self.classTitleLabel, keyPath: "text") <~ self.viewModel.classTitle.producer.map { x in x as? AnyObject }
        DynamicProperty(object: self.classDetailsLabel, keyPath: "text") <~ self.viewModel.classDetails.producer.map { x in x as? AnyObject }
        
        // Do any additional setup after loading the view.
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        
        let deleteAction = UIPreviewAction(title: NSLocalizedString("delete_classroom", comment: "Delete Class"), style: .Destructive, handler: { (previewAction, viewController) -> Void in
            print("delete")
        })
        
        return [deleteAction]
    }

    deinit {
        self.viewModel.save()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationController = segue.destinationViewController as! ClassMetaController
        destinationController.classroom = classroom
    }

}
