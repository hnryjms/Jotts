//
//  ClassroomViewModel.swift
//  Jotts
//
//  Created by Hank Brekke on 12/11/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import Foundation

class BaseViewModel {
    lazy var core: ObjectCore = {
        return AppDelegate.sharedDelegate().core
    }()
    
    fileprivate var _classroom: Classroom?
    var classroom: Classroom? {
        get {
            return _classroom
        }
        set(newClassroom) {
            _classroom = nil
            
            guard let classroom = newClassroom else {
                // There's nothing left to do if `classroom` is being unset.
                return
            }
            
            self.initialValues(classroom)
            
            _classroom = newClassroom
            
            self.setupBindings(classroom)
        }
    }
    
    func initialValues(_ classroom: Classroom) {
        print("Unimplemented default initial values.")
    }
    
    func setupBindings(_ classroom: Classroom) {
        print("Unimplemented default bindings.")
    }
}
