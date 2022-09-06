//
//  TaskStorage.swift
//  ToDue
//
//  Created by Niklas Kuder on 01.09.22.
//

import Foundation
import Combine
import CoreData

class TaskStorage: NSObject, ObservableObject {
    var tasks = CurrentValueSubject<[Task], Never>([])
    private let taskFetchController: NSFetchedResultsController<Task>
    
    static let shared: TaskStorage = TaskStorage()
    
    private override init() {
        let request = Task.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.date, ascending: true)]
        taskFetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        taskFetchController.delegate = self
        do {
            try taskFetchController.performFetch()
            tasks.value = taskFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func add(title: String, description: String, date: Date) {
        let task = Task(context: PersistenceController.shared.persistentContainer.viewContext)
        task.date = date
        task.taskDescription = description
        task.taskTitle = title
        task.isCompleted = false
        task.id = UUID()
        task.subTasks = []
        try? PersistenceController.shared.persistentContainer.viewContext.save()
    }
    
    func update(_ task: Task, title: String?, description: String?, date: Date?, isCompleted: Bool?) {
        PersistenceController.shared.persistentContainer.viewContext.performAndWait {
            task.isCompleted = isCompleted ?? task.isCompleted
            task.taskDescription = description ?? task.taskDescription!
            task.taskTitle = title ?? task.taskTitle!
            task.date = date ?? task.date!
            try? PersistenceController.shared.persistentContainer.viewContext.save()
        }
    }
    
    func delete(_ task: Task) {
        PersistenceController.shared.persistentContainer.viewContext.delete(task)
        do {
            try PersistenceController.shared.persistentContainer.viewContext.save()
        } catch {
            PersistenceController.shared.persistentContainer.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}

extension TaskStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tasks = controller.fetchedObjects as? [Task] else { return }
        print("Context has changed, reloading tasks")
        self.tasks.value = tasks
    }
}
