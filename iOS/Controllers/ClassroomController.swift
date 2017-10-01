//
//  ClassroomController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class ClassroomViewModel: BaseViewModel<Classroom> {
    lazy var classTitle: MutableProperty<String?> = {
        return MutableProperty<String?>(self.subject?.title)
    }()
    lazy var classDetails: MutableProperty<String?> = {
        return MutableProperty<String?>(self.subject?.room)
    }()
    lazy var tintColor: MutableProperty<UIColor?> = {
        return MutableProperty<UIColor?>(UIColor(fromHex: self.subject?.color))
    }()
    
    func save() {
        guard let classroom = self.subject else {
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
    
    override func initialValues(_ classroom: Classroom) {
        self.classTitle.value = classroom.title
    }
    
    override func setupBindings(_ classroom: Classroom) {
        self.classTitle <~ classroom.rac_title
        self.classDetails <~ classroom.rac_details
        self.tintColor <~ classroom.rac_color.map { UIColor(fromHex: $0) }
    }
}

class ClassroomController: UIViewController {
    let viewModel: ClassroomViewModel = {
        return ClassroomViewModel()
    }()
    var classroom: Classroom? {
        get {
            return self.viewModel.subject
        }
        set(newClassroom) {
            self.viewModel.subject = newClassroom
        }
    }
    
    @IBOutlet weak var classTitleLabel: UILabel!
    @IBOutlet weak var classDetailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.classTitleLabel.reactive.text <~ self.viewModel.classTitle.producer
        self.classDetailsLabel.reactive.text <~ self.viewModel.classDetails.producer

        self.topNavigationController!.navigationBar.reactive.makeBindingTarget { $0.tintColor = $1 } as BindingTarget<UIColor?> <~ self.viewModel.tintColor.producer

        // Do any additional setup after loading the view.
    }

    override var previewActionItems : [UIPreviewActionItem] {
        let deleteAction = UIPreviewAction(
                title: NSLocalizedString("ClassroomController.deleteClass", comment: "Delete Class"),
                style: .destructive,
                handler: { (previewAction, viewController) -> Void in
                    print("delete")
                }
        )
        
        return [deleteAction]
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if self.traitCollection.horizontalSizeClass == .regular {
            let splitViewController = UIApplication.shared.delegate!.window!!.rootViewController as! UISplitViewController
            self.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        } else {
            self.navigationItem.leftBarButtonItem = nil
        }
    }

    deinit {
        self.viewModel.save()

        if let topNavigationController = self.topNavigationController {
            topNavigationController.navigationBar.tintColor = nil
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as! UINavigationController
        let classMetaController = destinationController.topViewController as! ClassMetaController
        classMetaController.classroom = classroom
    }

    @IBAction func unwindToClassroom(unwindSegue: UIStoryboardSegue) {
        // We already save when the child controller is `deinit`'d
    }

}
