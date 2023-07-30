//
//  DataStorage.swift
//  ToDue
//
//  Created by Niklas Kuder on 30.07.23.
//

import Foundation
import CoreData

class DataStorage {
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}
