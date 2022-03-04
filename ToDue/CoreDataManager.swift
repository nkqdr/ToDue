//
//  CoreDataManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import Foundation
import CoreData

class CoreDateManager {
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data failed to initialize \(error.localizedDescription)")
            }
        }
    }
    
    func saveTask(taskDescription: String, date: Date) {
        let task = Task(context: persistentContainer.viewContext)
        task.date = date
        task.taskDescription = taskDescription
        
        do {
            try persistentContainer.viewContext.save()
            print("Task saved!")
        } catch {
            print("Failed to save task \(error)")
        }
    }
    
    func getAllTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func deleteTask(task: Task) {
        persistentContainer.viewContext.delete(task)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}
