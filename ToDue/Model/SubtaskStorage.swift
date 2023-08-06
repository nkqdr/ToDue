//
//  SubtaskStorage.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.09.22.
//

import Foundation
import Combine
import CoreData

class SubtaskFetchController: NSObject, ObservableObject {
    static let all = SubtaskFetchController()
    var subTasks = CurrentValueSubject<[SubTask], Never>([])
    private let subTaskFetchController: NSFetchedResultsController<SubTask>
    
    public convenience init(task: Task) {
        self.init(predicate: NSPredicate(format: "task == %@", task))
    }
    
    public convenience init(scheduledAt: Date) {
        let startOfDay = Calendar.current.startOfDay(for: scheduledAt)
        let nextDay = Calendar.current.date(byAdding: DateComponents(day: 1), to: scheduledAt) ?? scheduledAt
        let startOfNextDay = Calendar.current.startOfDay(for: nextDay)
        self.init(predicate: NSPredicate(format: "scheduledDate < %@ && scheduledDate >= %@", startOfNextDay as NSDate, startOfDay as NSDate))
    }
    
    private init(
        sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(keyPath: \SubTask.createdAt, ascending: true)],
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext = PersistenceController.shared.persistentContainer.viewContext
    ) {
        let request = SubTask.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        subTaskFetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
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
    
}

extension SubtaskFetchController: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let subTasks = controller.fetchedObjects as? [SubTask] else { return }
        self.subTasks.value = subTasks
    }
}

class SubtaskStorage: DataStorage {
    static let main: SubtaskStorage = SubtaskStorage(context: PersistenceController.shared.persistentContainer.viewContext)
    
    func add(on date: Date, title: String) {
        let subTask = SubTask(context: self.context)
        subTask.title = title
        subTask.id = UUID()
        subTask.isCompleted = false
        subTask.createdAt = Date()
        subTask.scheduledDate = date
        
        try? self.context.save()
    }
    
    func add(to task: Task, title: String, scheduledDate: Date?) {
        let subTask = SubTask(context: self.context)
        subTask.title = title
        subTask.id = UUID()
        subTask.isCompleted = false
        subTask.scheduledDate = scheduledDate
        subTask.createdAt = Date()
        
        task.addToSubTasks(subTask)
        try? self.context.save()
    }
    
    func update(_ subTask: SubTask, title: String?, isCompleted: Bool?, scheduledDate: Date?) {
        self.context.performAndWait {
            subTask.title = title ?? subTask.title
            subTask.isCompleted = isCompleted ?? subTask.isCompleted
            subTask.scheduledDate = scheduledDate
            try? self.context.save()
        }
    }
    
    func delete(_ subTask: SubTask) {
        self.context.delete(subTask)
        do {
            try self.context.save()
        } catch {
            self.context.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}
