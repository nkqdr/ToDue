//
//  PendingTaskViewModel.swift
//  ToDue
//
//  Created by Niklas Kuder on 30.07.23.
//

import Foundation
import Combine

class PendingTaskViewModel: ObservableObject {
    @Published var incompleteTasks: [Task] = [] {
        didSet {
            setDisplayedTasks()
        }
    }
    @Published var displayedTasks: [Task] = []
    @Published var selectedCategory: TaskCategory? {
        didSet {
            setDisplayedTasks()
        }
    }
    
    private var taskCancellable: AnyCancellable?
    private var taskFetchController: TaskFetchController
    
    public init() {
        self.taskFetchController = TaskFetchController(predicate: NSPredicate(format: "isCompleted == NO"))
        let taskPublisher = self.taskFetchController.tasks.eraseToAnyPublisher()
        
        self.taskCancellable = taskPublisher.sink { tasks in
            self.incompleteTasks = tasks
        }
    }
    
    private func setDisplayedTasks() {
        if let category = self.selectedCategory {
            self.displayedTasks = incompleteTasks.filter { $0.category == category }
        } else {
            displayedTasks = incompleteTasks
        }
    }
}

