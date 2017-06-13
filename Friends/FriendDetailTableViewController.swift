//
//  FriendDetailTableViewController.swift
//  Friends
//
//  Created by Maria on 5/26/17.
//  Copyright © 2017 Maria Notohusodo. All rights reserved.
//

import UIKit
import CoreData

protocol FriendDetailDelegate {
    func didFinish(viewController: FriendDetailTableViewController, didSave: Bool)
}

class FriendDetailTableViewController: UITableViewController {

    @IBOutlet weak var first: UITextField!
    
    @IBOutlet weak var last: UITextField!
    var friend: Friend?
    var context: NSManagedObjectContext!
    var delegate: FriendDetailDelegate?
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        delegate?.didFinish(viewController: self, didSave: false)
    }
    
    @IBAction func addFriend(_ sender: UIBarButtonItem) {
        
        guard let entry = friend else { return }
        

        entry.first = first.text
        entry.last = last.text

        delegate?.didFinish(viewController: self, didSave: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let friend = friend else { return }
        
        first.text = friend.first
        last.text = friend.last
   
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
}
