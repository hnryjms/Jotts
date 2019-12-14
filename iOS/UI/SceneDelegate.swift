//
//  SceneDelegate.swift
//  Jotts
//
//  Created by Hank Brekke on 10/13/19.
//  Copyright © 2019 Hank Brekke. All rights reserved.
//

import UIKit
import SwiftUI

#if targetEnvironment(macCatalyst)
let isMacOS = true
#else
let isMacOS = false
protocol NSToolbarDelegate { }
#endif

class SceneDelegate: UIResponder, UIWindowSceneDelegate, NSToolbarDelegate {

    var window: UIWindow?

    private func schedule() -> DailySchedule {
        let building = AppDelegate.sharedDelegate().building

        return try! building.schedule()
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let context = AppDelegate.sharedDelegate().persistentContainer.viewContext
        let contentView = Classrooms(schedule: DailyScheduleObservable(schedule: self.schedule()))
            .environment(\.managedObjectContext, context)

        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)

            let hostingController = DarkHostingController(rootView: contentView)
            hostingController.view.backgroundColor = UIColor.Jotts.background

            window.rootViewController = hostingController

            #if targetEnvironment(macCatalyst)
            if let titlebar = windowScene.titlebar {
                let toolbar = NSToolbar(identifier: .jotts)

                toolbar.delegate = self
                toolbar.allowsUserCustomization = true

                titlebar.titleVisibility = .hidden
                titlebar.toolbar = toolbar
            }
            #endif

            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        AppDelegate.sharedDelegate().responder.save()
    }

#if targetEnvironment(macCatalyst)
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .addClassroom:
            let button = NSToolbarItem(itemIdentifier: itemIdentifier)
            button.label = "Add Classroom"
            button.toolTip = "Add a new classroom"
            button.image = UIImage(systemName: "plus")
            button.isBordered = true
            button.target = AppDelegate.sharedDelegate().responder
            button.action = #selector(AppActions.addClassroom)
            return button
        default:
            return nil
        }
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .addClassroom
        ]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .addClassroom
        ]
    }
#endif
}

#if targetEnvironment(macCatalyst)
fileprivate extension NSToolbar.Identifier {
    static let jotts = NSToolbar.Identifier("Jotts")
}

fileprivate extension NSToolbarItem.Identifier {
    static let addClassroom = NSToolbarItem.Identifier("Add Classroom")
}
#endif
