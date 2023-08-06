//
//  TaskStorage.swift
//  ToDue
//
//  Created by Niklas Kuder on 01.09.22.
//

import Foundation
import Combine
import CoreData

class TaskFetchController: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    static let all = TaskFetchController()
    private let fetchedResultsController: RichFetchedResultsController<Task>
    var tasks = CurrentValueSubject<[Task], Never>([])
    
    public convenience init(scheduledAt: Date) {
        let startOfDay = Calendar.current.startOfDay(for: scheduledAt)
        let nextDay = Calendar.current.date(byAdding: DateComponents(day: 1), to: scheduledAt) ?? scheduledAt
        let startOfNextDay = Calendar.current.startOfDay(for: nextDay)
        self.init(predicate: NSPredicate(format: "scheduledDate < %@ && scheduledDate >= %@", startOfNextDay as NSDate, startOfDay as NSDate))
    }
    
    public init(sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(keyPath: \Task.date, ascending: true)], predicate: NSPredicate? = nil) {
        let request = RichFetchRequest<Task>(entityName: "Task")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        request.relationshipKeyPathsForRefreshing = [
            #keyPath(Task.category.categoryColorRed),
            #keyPath(Task.category.categoryColorGreen),
            #keyPath(Task.category.categoryColorBlue)
        ]
        fetchedResultsController = RichFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            tasks.value = fetchedResultsController.fetchedObjects as? [Task] ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let tasks = controller.fetchedObjects as? [Task] else { return }
        print("Context has changed, reloading tasks")
        self.tasks.value = tasks
    }
}

class TaskStorage: DataStorage {
    static let main = TaskStorage(context: PersistenceController.shared.persistentContainer.viewContext)
    
    func toggleCompleted(for task: Task) {
        if !task.isCompleted { // Task is going to be completed
            Utils.cancelNotification(for: task)
        }
        self.context.performAndWait {
            if task.completedAt == nil {
                task.completedAt = Date()
            } else {
                task.completedAt = nil
            }
            task.isCompleted = !task.isCompleted
            try? self.context.save()
        }
    }
    
    func add(title: String, description: String, date: Date, category: TaskCategory?, scheduledDate: Date? = nil) -> Task {
        let task = Task(context: self.context)
        task.date = date
        task.taskDescription = description
        task.taskTitle = title
        task.isCompleted = false
        task.category = category
        task.scheduledDate = scheduledDate
        task.id = UUID()
        task.subTasks = []
        try? self.context.save()
        return task
    }
    
    func update(_ task: Task, title: String?, description: String?, date: Date?, isCompleted: Bool?, category: TaskCategory?, scheduledDate: Date?) {
        self.context.performAndWait {
            task.isCompleted = isCompleted ?? task.isCompleted
            if let isCompleted, isCompleted {
                task.completedAt = Date()
            }
            task.taskDescription = description ?? task.taskDescription!
            task.taskTitle = title ?? task.taskTitle!
            task.category = category
            task.date = date ?? task.date!
            task.scheduledDate = scheduledDate
            try? self.context.save()
        }
    }
    
    func delete(_ task: Task) {
        Utils.cancelNotification(for: task)
        self.context.delete(task)
        do {
            try self.context.save()
        } catch {
            self.context.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}
