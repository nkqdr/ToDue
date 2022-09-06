//
//  PersistenceController.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import Foundation
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let persistentContainer: NSPersistentCloudKitContainer
    
    init(inMemory: Bool = false) {
        persistentContainer = NSPersistentCloudKitContainer(name: "DataModel")
        
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.niklaskuder.ToDue")!
        let storeURL = containerURL.appendingPathComponent("DataModel.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.niklaskuder.ToDue")
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data failed to initialize \(error.localizedDescription)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - FetchRequests
    
    private func executeFetch<T>(_ request: NSFetchRequest<T>) -> [T] {
        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            return []
        }
    }
    
    func getIncompleteTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isCompleted = %d", false)
        
        return executeFetch(fetchRequest)
    }
    
    func getAllTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        return executeFetch(fetchRequest)
    }
}
