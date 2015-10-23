//
//  MyClassesController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import CoreData

class MyClassesController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    lazy var core: ObjectCore = {
        return AppDelegate.sharedDelegate().core
    }()
    
    lazy var fetchController: NSFetchedResultsController = {
        
        let fetchRequest = self.core.fetch_classes()
        
        let controller =  NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.core.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "MyClassesController")
        
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //print("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = self.fetchController.sections else {
            return 0
        }
        
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchController.sections![section];
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MetaCell", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        default:
            return
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            print("Update cell")
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let core = self.core
        
        let classroom: Classroom
        switch segue.identifier! {
        case "addClass":
            classroom = core.newClassroom()
        case "viewClass":
            classroom = self.fetchController.objectAtIndexPath(self.tableView.indexPathForSelectedRow!) as! Classroom
        default:
            abort()
            break
        }
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let destinationController = navigationController.viewControllers[0] as! ClassroomController
        destinationController.classroom = classroom
    }

}
