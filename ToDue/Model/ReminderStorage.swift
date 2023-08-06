//
//  ReminderStorage.swift
//  ToDue
//
//  Created by Niklas Kuder on 30.07.23.
//

import Foundation
import CoreData
import Combine

class ReminderFetchController: NSObject, ObservableObject {
    static let all = ReminderFetchController()
    var reminders = CurrentValueSubject<[Reminder], Never>([])
    private let reminderFetchController: NSFetchedResultsController<Reminder>
    
    public convenience init(task: Task) {
        let predicate = NSPredicate(format: "task == %@", task)
        self.init(predicate: predicate)
    }
    
    private init(
        sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(keyPath: \Reminder.dateTime, ascending: true)],
        predicate: NSPredicate? = nil,
        context: NSManagedObjectContext = PersistenceController.shared.persistentContainer.viewContext
    ) {
        let request = Reminder.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        reminderFetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        reminderFetchController.delegate = self
        do {
            try reminderFetchController.performFetch()
            reminders.value = reminderFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
}

extension ReminderFetchController: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let reminders = controller.fetchedObjects as? [Reminder] else { return }
        self.reminders.value = reminders
    }
}


class ReminderStorage: DataStorage {
    static let main = ReminderStorage(context: PersistenceController.shared.persistentContainer.viewContext)
    
    func add(to task: Task, scheduledDate: Date) {
        let reminder = Reminder(context: self.context)
        reminder.id = UUID()
        reminder.dateTime = scheduledDate
        
        task.addToReminders(reminder)
        try? self.context.save()
        
        Utils.scheduleReminderNotification(reminder: reminder)
    }
    
    func delete(_ reminder: Reminder) {
        Utils.cancelNotification(for: reminder)
        self.context.delete(reminder)
        do {
            try self.context.save()
        } catch {
            self.context.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}
