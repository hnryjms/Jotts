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
    var appResponder: AppKitActions?
    let responder = AppResponder()

    lazy var persistentContainer: NSPersistentContainer = {
        let modelURL = Bundle.main.url(forResource: "Jotts", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!

        let persistentContainer = NSPersistentContainer(name: "Jotts", managedObjectModel: model)
        persistentContainer.loadPersistentStores { (description, err) in
            if let error = err {
                fatalError("Unable to load persistent stores, \(error)")
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
            fatalError("Unable to create default Building, \(error)")
        }
    }()

    class func sharedDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        #if targetEnvironment(macCatalyst)
        let bundlePath = Bundle.main.builtInPlugInsURL!.appendingPathComponent("JottsAppKitGlue.bundle")
        if let bundle = Bundle(url: bundlePath) {
            guard bundle.load() else {
                fatalError("Unable to load AppKit extensions")
            }
            guard let glueClass = bundle.principalClass as? NSObject.Type else {
                fatalError("AppKit extension does not have principal class")
            }
            guard let glueResponder = glueClass.init() as? AppKitActions else {
                fatalError("AppKit extension does not conform to spec")
            }

            self.appResponder = glueResponder
        } else {
            fatalError("Unable to find AppKit extensions")
        }
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear
        #else
        UINavigationBar.appearance().barStyle = .black
        UITableView.appearance().backgroundColor = UIColor.Jotts.background
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear
        #endif

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

