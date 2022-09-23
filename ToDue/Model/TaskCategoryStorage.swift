//
//  TaskStorage.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.09.22.
//

import Foundation
import Combine
import CoreData

class TaskCategoryStorage: NSObject, ObservableObject {
    var categories = CurrentValueSubject<[TaskCategory], Never>([])
    private let categoryFetchController: NSFetchedResultsController<TaskCategory>
    
    static let shared: TaskCategoryStorage = TaskCategoryStorage()
    
    private override init() {
        let request = TaskCategory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskCategory.categoryTitle, ascending: true)]
        categoryFetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: PersistenceController.shared.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        categoryFetchController.delegate = self
        do {
            try categoryFetchController.performFetch()
            categories.value = categoryFetchController.fetchedObjects ?? []
        } catch {
            NSLog("Error: could not fetch objects")
        }
    }
    
    func add(title: String) {
        let category = TaskCategory(context: PersistenceController.shared.persistentContainer.viewContext)
        category.categoryTitle = title
        category.id = UUID()
        category.tasks = []
        try? PersistenceController.shared.persistentContainer.viewContext.save()
    }
    
    func update(_ category: TaskCategory, title: String?) {
        PersistenceController.shared.persistentContainer.viewContext.performAndWait {
            category.categoryTitle = title ?? category.categoryTitle!
            try? PersistenceController.shared.persistentContainer.viewContext.save()
        }
    }
    
    func delete(_ category: TaskCategory) {
        PersistenceController.shared.persistentContainer.viewContext.delete(category)
        do {
            try PersistenceController.shared.persistentContainer.viewContext.save()
        } catch {
            PersistenceController.shared.persistentContainer.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
}

extension TaskCategoryStorage: NSFetchedResultsControllerDelegate {
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let categories = controller.fetchedObjects as? [TaskCategory] else { return }
        print("Context has changed, reloading tasks")
        self.categories.value = categories
    }
}
