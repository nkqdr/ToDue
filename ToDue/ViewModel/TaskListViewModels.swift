//
//  PendingTaskViewModel.swift
//  ToDue
//
//  Created by Niklas Kuder on 30.07.23.
//

import Foundation
import Combine

class CompleteTasksViewModel: ObservableObject {
    @Published var completeTasks: [Task] = [] {
        didSet {
            setDisplayedTasks()
        }
    }
    @Published var displayedTasks: [Task] = []
    @Published var searchValue: String = "" {
        didSet {
            setDisplayedTasks()
        }
    }
    
    private var taskCancellable: AnyCancellable?
    private var taskFetchController: TaskFetchController
    
    public init() {
        self.taskFetchController = TaskFetchController(predicate: NSPredicate(format: "isCompleted == YES"))
        let taskPublisher = self.taskFetchController.tasks.eraseToAnyPublisher()
        
        self.taskCancellable = taskPublisher.sink { tasks in
            self.completeTasks = tasks
        }
    }
    
    private func setDisplayedTasks() {
        if searchValue != "" {
            DispatchQueue.global(qos: .userInitiated).async {
                let filtered = self.completeTasks.filter { task in
                    let upperSearch = self.searchValue.uppercased()
                    let titleContainsValue = task.taskTitle!.uppercased().contains(upperSearch)
                    let descContainsValue = task.taskDescription?.uppercased().contains(upperSearch) ?? false
                    let hasMatchingSubTask = task.subTaskArray.contains { $0.wrappedTitle.uppercased().contains(upperSearch) }
                    return titleContainsValue || descContainsValue || hasMatchingSubTask
                }
                DispatchQueue.main.async {
                    self.displayedTasks = filtered
                }
            }
        } else {
            self.displayedTasks = self.completeTasks
        }
    }
}

class PendingTasksViewModel: ObservableObject {
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

