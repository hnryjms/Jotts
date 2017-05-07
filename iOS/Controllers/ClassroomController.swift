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

class ClassroomViewModel: BaseViewModel {
    lazy var classTitle: MutableProperty<String?> = {
        return MutableProperty<String?>(self.classroom?.title)
    }()
    lazy var classDetails: MutableProperty<String?> = {
        return MutableProperty<String?>(self.classroom?.room)
    }()
    lazy var tintColor: MutableProperty<UIColor?> = {
        return MutableProperty<UIColor?>(UIColor(fromHex: self.classroom?.color))
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

        self.classTitleLabel.reactive.text <~ self.viewModel.classTitle.producer
        self.classDetailsLabel.reactive.text <~ self.viewModel.classDetails.producer
        self.navigationController!.view.reactive.makeBindingTarget { $0.tintColor = $1 } as BindingTarget<UIColor>
                <~ self.viewModel.tintColor.producer.skipNil()

        // Do any additional setup after loading the view.
    }
    
    override var previewActionItems : [UIPreviewActionItem] {
        
        let deleteAction = UIPreviewAction(
                title: NSLocalizedString("delete_classroom", comment: "Delete Class"),
                style: .destructive,
                handler: { (previewAction, viewController) -> Void in
                    print("delete")
                }
        )
        
        return [deleteAction]
    }

    deinit {
        self.viewModel.save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination as! ClassMetaController
        destinationController.classroom = classroom
    }

}
