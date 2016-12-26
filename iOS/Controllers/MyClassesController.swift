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
    
    lazy var fetchController: NSFetchedResultsController<Classroom> = {
        
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
        self.registerForPreviewing(with: self, sourceView: self.view)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = self.tableView.indexPathForRow(at: location) {
            let cell = self.tableView.cellForRow(at: indexPath) as! MyClassesMetaCell
            let classroom = cell.classroom!
            
            let cellRect = self.tableView.convert(cell.bounds, to: previewingContext.sourceView)
            
            // Hide the 1px border on the bottom of the cell for cleaner presentation.
            previewingContext.sourceRect = CGRect(x: cellRect.origin.x, y: cellRect.origin.y, width: cellRect.size.width, height: cellRect.size.height-1)
            
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Classroom") as! ClassroomController
            controller.classroom = classroom
            
            return controller
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let controller = viewControllerToCommit as! ClassroomController
        let classroom = controller.classroom!
        
        self.performSegue(withIdentifier: "viewClass", sender: classroom)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = self.fetchController.sections else {
            return 0
        }
        
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchController.sections![section];
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MetaCell", for: indexPath) as! MyClassesMetaCell

        let classroom = self.fetchController.object(at: indexPath)
        cell.classroom = classroom

        return cell
    }
    
    
    // MARK: - Fetched results controller
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            self.tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            print("Update cell")
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let core = self.core
        
        let classroom: Classroom
        switch segue.identifier! {
        case "addClass":
            classroom = core.newClassroom()
        case "viewClass":
            if let indexPath = self.tableView.indexPathForSelectedRow {
                classroom = self.fetchController.object(at: indexPath)
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
        
        let navigationController = segue.destination as! UINavigationController
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
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let animation = {
            if highlighted {
                self.contentView.backgroundColor = self.colorBar!.backgroundColor
            } else {
                self.contentView.backgroundColor = nil
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: animation)
        } else {
            animation()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        self.setHighlighted(selected, animated: animated)
    }
}
