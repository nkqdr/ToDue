//
//  TaskCategoryManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.09.22.
//

import Foundation
import Combine

class TaskCategoryManager: ObservableObject {
    static let shared: TaskCategoryManager = TaskCategoryManager()
    @Published var categories: [TaskCategory] = []
    
    private var categoryCancellable: AnyCancellable?
    
    init(categoryPublisher: AnyPublisher<[TaskCategory], Never> = TaskCategoryStorage.shared.categories.eraseToAnyPublisher()) {
        categoryCancellable = categoryPublisher.sink { categories in
            print("Updating categories...")
            self.categories = categories
        }
    }
    
    
    // MARK: - Intents
    
    func saveCategory(_ categoryEditor: TaskCategoryEditor) {
        if let category = categoryEditor.category {
            TaskCategoryStorage.shared.update(category, title: categoryEditor.title)
        } else {
            TaskCategoryStorage.shared.add(title: categoryEditor.title)
        }
    }
    
    func deleteCategory(_ category: TaskCategory) {
        TaskCategoryStorage.shared.delete(category)
    }
}
