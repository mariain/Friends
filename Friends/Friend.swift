//
//  Friend.swift
//  Friends
//
//  Created by Maria on 5/30/17.
//  Copyright © 2017 Maria Notohusodo. All rights reserved.
//

import CoreData

class Friend: NSManagedObject {
    @NSManaged var first: String?
    @NSManaged var last: String?
}
