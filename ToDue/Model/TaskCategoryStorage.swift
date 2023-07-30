//
//  TaskCategoryStorage.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.09.22.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class TaskCategoryFetchController: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    var categories = CurrentValueSubject<[TaskCategory], Never>([])
    private let categoryFetchController: NSFetchedResultsController<TaskCategory>
    
    public init(sortDescriptors: [NSSortDescriptor]? = [NSSortDescriptor(keyPath: \TaskCategory.categoryTitle, ascending: true)], predicate: NSPredicate? = nil) {
        let request = TaskCategory.fetchRequest()
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
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
    
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let categories = controller.fetchedObjects as? [TaskCategory] else { return }
        print("Context has changed, reloading categories")
        self.categories.value = categories
    }
}

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
    
    func add(title: String, useDefaultColor: Bool, color: Color) {
        let category = TaskCategory(context: PersistenceController.shared.persistentContainer.viewContext)
        let components = UIColor(color).cgColor.components
        if !useDefaultColor, let comps = components {
            category.categoryColorRed = Double(comps[0])
            category.categoryColorGreen = Double(comps[1])
            category.categoryColorBlue = Double(comps[2])
        } else {
            category.categoryColorRed = -1
            category.categoryColorGreen = -1
            category.categoryColorBlue = -1
        }
        category.categoryTitle = title
        category.id = UUID()
        category.tasks = []
        try? PersistenceController.shared.persistentContainer.viewContext.save()
    }
    
    func update(_ category: TaskCategory, title: String?, useDefaultColor: Bool, color: Color) {
        let components = UIColor(color).cgColor.components
        PersistenceController.shared.persistentContainer.viewContext.performAndWait {
            if !useDefaultColor, let comps = components {
                category.categoryColorRed = Double(comps[0])
                category.categoryColorGreen = Double(comps[1])
                category.categoryColorBlue = Double(comps[2])
            } else {
                category.categoryColorRed = -1
                category.categoryColorGreen = -1
                category.categoryColorBlue = -1
            }
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
        print("Context has changed, reloading categories")
        self.categories.value = categories
    }
}
