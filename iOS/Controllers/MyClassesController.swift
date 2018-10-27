//
//  MyClassesController.swift
//  Jotts
//
//  Created by Hank Brekke on 10/17/15.
//  Copyright © 2015 Hank Brekke. All rights reserved.
//

import UIKit
import CoreData
import ReactiveSwift
import ReactiveCocoa

class MyClassesController: UITableViewController, NSFetchedResultsControllerDelegate {
    
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
        case "viewClass", "previewClass":
            if let selectedCell = sender as? MyClassesMetaCell {
                classroom = selectedCell.classroom!
            } else if let selectedClassroom = sender as? Classroom {
                classroom = selectedClassroom
            } else {
                abort()
                break
            }
        default:
            abort()
            break
        }

        let navigationController = segue.destination as! UINavigationController
        let destinationController = navigationController.viewControllers[0] as! ClassroomController
        destinationController.classroom = classroom

        if (segue.identifier == "previewClass") {
            navigationController.setNavigationBarHidden(true, animated: false)
        }
    }

}

class MyClassesMetaCell: UITableViewCell {
    @IBOutlet var colorBar: UIView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var metaLabel: UILabel?
    
    var classroom: Classroom? {
        didSet {
            if let nextClassroom = self.classroom {
                self.colorBar!.backgroundColor = UIColor(fromHex: nextClassroom.color!)
                self.nameLabel!.reactive.text <~ nextClassroom.rac_title
                self.metaLabel!.reactive.text <~ nextClassroom.rac_details
            }
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
