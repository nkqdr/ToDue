//
//  CoreDataManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import Foundation
import CoreData
import WidgetKit

class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.niklaskuder.ToDue")!
        let storeURL = containerURL.appendingPathComponent("DataModel.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data failed to initialize \(error.localizedDescription)")
            }
        }
        self.persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    func removeAllSubTasks(from task: Task) {
        task.removeFromSubTasks(task.subTasks!)
        try! persistentContainer.viewContext.save()
    }
    
    func addSubTask(to task: Task, subTaskTitle: String) {
        let subTask = SubTask(context: persistentContainer.viewContext)
        subTask.title = subTaskTitle
        subTask.id = UUID()
        subTask.isCompleted = false
        
        task.addToSubTasks(subTask)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to add subtask \(error)")
        }
    }
    
    func saveTask(taskDescription: String, date: Date) {
        let task = Task(context: persistentContainer.viewContext)
        task.date = date
        task.taskDescription = taskDescription
        task.isCompleted = false
        task.id = UUID()
        task.subTasks = []
        WidgetCenter.shared.reloadAllTimelines()
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to save task \(error)")
        }
    }
    
    func deleteSubTask(subTask: SubTask) {
        persistentContainer.viewContext.delete(subTask)
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
    
    func getAllTasks() -> [Task] {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do {
            var allTasks = try persistentContainer.viewContext.fetch(fetchRequest)
            allTasks.sort {
                $0.date! < $1.date!
            }
            return allTasks
        } catch {
            return []
        }
    }
    
    func toggleIsCompleted(for subTask: SubTask) {
        subTask.isCompleted.toggle()
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Failed to complete subtask \(error)")
        }
    }
    
    func updateTask(task: Task, description: String, date: Date, isCompleted: Bool) {
        persistentContainer.viewContext.performAndWait {
            task.isCompleted = isCompleted
            task.taskDescription = description
            task.date = date
            try? persistentContainer.viewContext.save()
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func deleteTask(task: Task) {
        persistentContainer.viewContext.delete(task)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
}
