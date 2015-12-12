//
//  ClassroomController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit

class ClassroomViewModel: BaseViewModel {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
