//
//  ClassroomController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit

class ClassroomController: UIViewController {
    lazy var core: ObjectCore = {
        return AppDelegate.sharedDelegate().core
    }()
    
    var classroom: Classroom?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let classroom = self.classroom else {
            // There's no point in continuing if the state here was invalid.
            return;
        }
        
        if let navigationController = self.navigationController {
            // Inside a navigaiton stack, we want to save if this controller is being popped
            // off of the stack (not displaying additional detail).
            
            if navigationController.viewControllers.indexOf(self) != nil {
                // This controller has been removed from the stack, so the user popped back.
                
                do {
                    try classroom.validate()
                } catch {
                    self.core.delete(classroom)
                }
                
                self.core.save()
            }
        }
    }

}
