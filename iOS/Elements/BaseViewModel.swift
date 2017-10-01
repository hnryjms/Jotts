//
//  ClassroomViewModel.swift
//  Jotts
//
//  Created by Hank Brekke on 12/11/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import Foundation

class BaseViewModel<T>: NSObject {
    lazy var core: ObjectCore = {
        return AppDelegate.sharedDelegate().core
    }()
    
    private var _subject: T?
    var subject: T? {
        get {
            return _subject
        }
        set(newSubject) {
            _subject = nil
            
            guard let subject = newSubject else {
                // There's nothing left to do if `classroom` is being unset.
                return
            }

            self.initialValues(subject)
            
            _subject = newSubject
            
            self.setupBindings(subject)
        }
    }
    
    func initialValues(_ subject: T) {
        print("Unimplemented default initial values.")
    }
    
    func setupBindings(_ subject: T) {
        print("Unimplemented default bindings.")
    }
}
