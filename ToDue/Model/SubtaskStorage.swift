//
//  SubtaskStorage.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.09.22.
//

import Foundation
import Combine
import CoreData

class SubtaskStorage: NSObject, ObservableObject {
    var subTasks = CurrentValueSubject<[SubTask], Never>([])
    private let subTaskFetchController: NSFetchedResultsController<SubTask>
    
    static let shared: SubtaskStorage = SubtaskStorage()
    
    public init(task: Task) {
        let request = SubTask.fetchRequest()
        request.predicate = NSPredicate(format: "task == %@", task)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SubTask.createdAt, ascending: true)]
        subTaskFetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        subTaskFetchController.delegate = self
        do {
            try subTaskFetchController.performFetch()
            subTasks.value = subTaskFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    private override init() {
        let request = SubTask.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SubTask.createdAt, ascending: true)]
        subTaskFetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        subTaskFetchController.delegate = self
        do {
            try subTaskFetchController.performFetch()
            subTasks.value = subTaskFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func add(on date: Date, title: String) {
        let subTask = SubTask(context: PersistenceController.shared.persistentContainer.viewContext)
        subTask.title = title
        subTask.id = UUID()
        subTask.isCompleted = false
        subTask.createdAt = Date()
        subTask.scheduledDate = date
        
        try? PersistenceController.shared.persistentContainer.viewContext.save()
    }
    
    func add(to task: Task, title: String, scheduledDate: Date?) {
        let subTask = SubTask(context: PersistenceController.shared.persistentContainer.viewContext)
        subTask.title = title
        subTask.id = UUID()
        subTask.isCompleted = false
        subTask.scheduledDate = scheduledDate
        subTask.createdAt = Date()
        
        task.addToSubTasks(subTask)
        try? PersistenceController.shared.persistentContainer.viewContext.save()
    }
    
    func update(_ subTask: SubTask, title: String?, isCompleted: Bool?, scheduledDate: Date?) {
        PersistenceController.shared.persistentContainer.viewContext.performAndWait {
            subTask.title = title ?? subTask.title
            subTask.isCompleted = isCompleted ?? subTask.isCompleted
            subTask.scheduledDate = scheduledDate
            try? PersistenceController.shared.persistentContainer.viewContext.save()
        }
    }
    
    func delete(_ subTask: SubTask) {
        PersistenceController.shared.persistentContainer.viewContext.delete(subTask)
        do {
            try PersistenceController.shared.persistentContainer.viewContext.save()
        } catch {
            PersistenceController.shared.persistentContainer.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}

extension SubtaskStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let subTasks = controller.fetchedObjects as? [SubTask] else { return }
        self.subTasks.value = subTasks
    }
}
