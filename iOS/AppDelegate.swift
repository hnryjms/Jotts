//
//  AppDelegate.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let responder = AppResponder()

    lazy var persistentContainer: NSPersistentContainer = {
        let modelURL = Bundle.main.url(forResource: "Jotts", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        let persistentContainer = NSPersistentContainer(name: "Jotts", managedObjectModel: model)
        persistentContainer.loadPersistentStores { (description, err) in
            if let error = err {
                abort()
            }
        }

        return persistentContainer
    }()

    lazy var building: Building = {
        do {
            let viewContext = self.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Building> = Building.fetchRequest()
            fetchRequest.returnsObjectsAsFaults = false
            let result = try viewContext.fetch(fetchRequest)

            if result.isEmpty {
                return Building(context: viewContext)
            } else {
                return result[0]
            }
        } catch {
            abort()
        }
    }()

    class func sharedDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UINavigationBar.appearance().barStyle = .black
        UITableView.appearance().backgroundColor = UIColor(white: 0.26, alpha: 1)
        UITableView.appearance().separatorStyle = .none

        return true
    }

    override var next: UIResponder? {
        get { self.responder }
    }

    override func buildMenu(with builder: UIMenuBuilder) {
        let fileDocumentNewClassroomCommand = UIKeyCommand(
            title: "New Classroom",
            action: #selector(AppActions.addClassroom),
            input: "n",
            modifierFlags: [ .command ]
        )

        let fileDocumentNewAssignmentCommand = UICommand(
            title: "New Assignment",
            action: #selector(AppActions.addAssignment),
            attributes: [ .disabled ]
        )

        let fileDocumentMenu = UIMenu(title: "", options: .displayInline, children: [
            fileDocumentNewClassroomCommand,
            fileDocumentNewAssignmentCommand
        ])

        builder.insertChild(fileDocumentMenu, atStartOfMenu: .file)
        builder.remove(menu: UIMenu.Identifier.format)
    }
}

