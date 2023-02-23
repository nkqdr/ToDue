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
    private let taskFetchController: RichFetchedResultsController<Task>
    
    static let shared: TaskStorage = TaskStorage()
    
    private override init() {
        let request = RichFetchRequest<Task>(entityName: "Task")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Task.date, ascending: true)]
        request.relationshipKeyPathsForRefreshing = [
            #keyPath(Task.category.categoryColorRed),
            #keyPath(Task.category.categoryColorGreen),
            #keyPath(Task.category.categoryColorBlue)
        ]
        taskFetchController = RichFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        taskFetchController.delegate = self
        do {
            try taskFetchController.performFetch()
            tasks.value = taskFetchController.fetchedObjects as? [Task] ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func toggleCompleted(for task: Task) {
        PersistenceController.shared.persistentContainer.viewContext.performAndWait {
            task.isCompleted = !task.isCompleted
            try? PersistenceController.shared.persistentContainer.viewContext.save()
        }
    }
    
    func add(title: String, description: String, date: Date, category: TaskCategory?) -> Task {
        let task = Task(context: PersistenceController.shared.persistentContainer.viewContext)
        task.date = date
        task.taskDescription = description
        task.taskTitle = title
        task.isCompleted = false
        task.category = category
        task.id = UUID()
        task.subTasks = []
        try? PersistenceController.shared.persistentContainer.viewContext.save()
        return task
    }
    
    func update(_ task: Task, title: String?, description: String?, date: Date?, isCompleted: Bool?, category: TaskCategory?, dailyTask: Date? = nil) {
        PersistenceController.shared.persistentContainer.viewContext.performAndWait {
            task.isCompleted = isCompleted ?? task.isCompleted
            task.taskDescription = description ?? task.taskDescription!
            task.taskTitle = title ?? task.taskTitle!
            task.category = category
            task.date = date ?? task.date!
            task.dailyTask = dailyTask ?? task.dailyTask
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
