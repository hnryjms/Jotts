//
//  MyClassesController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import CoreData

class MyClassesController: UITableViewController, NSFetchedResultsControllerDelegate, UIViewControllerPreviewingDelegate {
    
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
        self.registerForPreviewingWithDelegate(self, sourceView: self.view)
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = self.tableView.indexPathForRowAtPoint(location) {
            let cell = self.tableView.cellForRowAtIndexPath(indexPath) as! MyClassesMetaCell
            let classroom = cell.classroom!
            
            let cellRect = self.tableView.convertRect(cell.bounds, toView: previewingContext.sourceView)
            
            // Hide the 1px border on the bottom of the cell for cleaner presentation.
            previewingContext.sourceRect = CGRect(x: cellRect.origin.x, y: cellRect.origin.y, width: cellRect.size.width, height: cellRect.size.height-1)
            
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Classroom") as! ClassroomController
            controller.classroom = classroom
            
            return controller
        }
        
        return nil
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        let controller = viewControllerToCommit as! ClassroomController
        let classroom = controller.classroom!
        
        self.performSegueWithIdentifier("viewClass", sender: classroom)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MetaCell", forIndexPath: indexPath) as! MyClassesMetaCell

        let classroom = self.fetchController.objectAtIndexPath(indexPath) as! Classroom
        cell.classroom = classroom;

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
            if let indexPath = self.tableView.indexPathForSelectedRow {
                classroom = self.fetchController.objectAtIndexPath(indexPath) as! Classroom
            } else {
                classroom = sender as! Classroom
            }
        case "peekClass":
            let cell = sender as! MyClassesMetaCell
            classroom = cell.classroom!
        default:
            abort()
            break
        }
        
        let navigationController = segue.destinationViewController as! UINavigationController
        let destinationController = navigationController.viewControllers[0] as! ClassroomController
        destinationController.classroom = classroom
    }

}

class MyClassesMetaCell: UITableViewCell {
    @IBOutlet var colorBar: UIView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var metaLabel: UILabel?
    
    var classroom: Classroom? {
        didSet {
            // TODO: Configure cell
        }
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let animation = {
            if highlighted {
                self.contentView.backgroundColor = self.colorBar!.backgroundColor
            } else {
                self.contentView.backgroundColor = nil
            }
        }
        
        if animated {
            UIView.animateWithDuration(0.25, animations: animation)
        } else {
            animation()
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        self.setHighlighted(selected, animated: animated)
    }
}
