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
    let persistentContainer: NSPersistentCloudKitContainer
    
    private init() {
        persistentContainer = NSPersistentCloudKitContainer(name: "DataModel")
        
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.niklaskuder.ToDue")!
        let storeURL = containerURL.appendingPathComponent("DataModel.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.niklaskuder.ToDue")
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Core Data failed to initialize \(error.localizedDescription)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func removeAllSubTasks(from task: Task) {
        task.removeFromSubTasks(task.subTasks!)
        try? persistentContainer.viewContext.save()
    }
    
    func addSubTask(to task: Task, subTaskTitle: String) {
        let subTask = SubTask(context: persistentContainer.viewContext)
        subTask.title = subTaskTitle
        subTask.id = UUID()
        subTask.isCompleted = false
        subTask.createdAt = Date.now
        
        task.addToSubTasks(subTask)
        try? persistentContainer.viewContext.save()
    }
    
    func updateSubTask(_ subTask: SubTask, description: String) {
        persistentContainer.viewContext.performAndWait {
            subTask.title = description
            try? persistentContainer.viewContext.save()
        }
    }
    
    func saveTask(taskDescription: String, taskTitle: String, date: Date) {
        let task = Task(context: persistentContainer.viewContext)
        task.date = date
        task.taskDescription = taskDescription
        task.taskTitle = taskTitle
        task.isCompleted = false
        task.id = UUID()
        task.subTasks = []
        WidgetCenter.shared.reloadAllTimelines()
        try? persistentContainer.viewContext.save()
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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func toggleIsCompleted(for subTask: SubTask) {
        subTask.isCompleted.toggle()
        try? persistentContainer.viewContext.save()
    }
    
    func updateTask(task: Task, description: String, title: String, date: Date, isCompleted: Bool) {
        persistentContainer.viewContext.performAndWait {
            task.isCompleted = isCompleted
            task.taskDescription = description
            task.date = date
            task.taskTitle = title
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
