//
//  FriendListTableViewController.swift
//  Friends
//
//  Created by Maria on 5/26/17.
//  Copyright © 2017 Maria Notohusodo. All rights reserved.
//

import UIKit
import CoreData

class FriendListTableViewController: UITableViewController {
    
    var coreDataStack: CoreDataStack!

    var friendList: NSFetchedResultsController<Friend> = NSFetchedResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendList = friendListFetchedResultsController()

        
        
        
    }
    
    func friendListFetchedResultsController() -> NSFetchedResultsController<Friend> {
        let fetchedResultController = NSFetchedResultsController(fetchRequest: friendFetchRequest(), managedObjectContext: coreDataStack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        
        do {
            try fetchedResultController.performFetch()
            
        } catch let error as NSError {
            fatalError("Error: \(error.localizedDescription)")
        }
        
        return fetchedResultController
    }
    
    func friendFetchRequest() -> NSFetchRequest<Friend> {
        let fetchRequest = NSFetchRequest<Friend>(entityName: "Friend")
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "last", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]

        return fetchRequest
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return friendList.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendList.sections?[section].numberOfObjects ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let friend = friendList.object(at: indexPath)
        cell.textLabel?.text = friend.first
        cell.detailTextLabel?.text = friend.last
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailFriend" {
            
            guard let navigationController = segue.destination as? UINavigationController,
                let detailViewController = navigationController.topViewController as? FriendDetailTableViewController,
                let indexPath = tableView.indexPathForSelectedRow else {
                    fatalError("Application storyboard mis-configuration")
            }
            
            let friend = friendList.object(at: indexPath)
            
            let childContext =
                NSManagedObjectContext(
                    concurrencyType: .mainQueueConcurrencyType)
            childContext.parent = coreDataStack.mainContext
            
            
            let childEntry =
                childContext.object(with: friend.objectID)
                    as? Friend
            
            
            detailViewController.friend = childEntry
            detailViewController.context = childContext
            detailViewController.delegate = self
            
        } else if segue.identifier == "addFriend" {
            
            guard let navigationController = segue.destination as? UINavigationController,
                let detailViewController = navigationController.topViewController as? FriendDetailTableViewController else {
                    fatalError("Application storyboard mis-configuration")
            }
            
            let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            childContext.parent = coreDataStack.mainContext
            
            let newFriend = Friend(context: childContext)
            
            detailViewController.friend = newFriend
            detailViewController.context = childContext
            detailViewController.delegate = self
        }
    }

}
extension FriendListTableViewController: NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension FriendListTableViewController: FriendDetailDelegate {
    
    func didFinish(viewController: FriendDetailTableViewController, didSave: Bool) {
        
        guard didSave,
            let context = viewController.context,
            context.hasChanges else {
                dismiss(animated: true)
                return
        }
        
        context.perform {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Error: \(error.localizedDescription)")
            }

            self.coreDataStack.saveContext()
        }
        
        dismiss(animated: true)
    }
}

