//
//  TaskManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 16.08.22.
//

import Foundation
import WidgetKit
import Combine

class TaskManager: ObservableObject, SubtaskModifier, TaskModifier {
    static let shared: TaskManager = TaskManager()
    @Published private(set) var container = PersistenceController.shared.persistentContainer
    
    @Published var incompleteTasks: [Task] = []
    @Published var completeTasks: [Task] = []
    @Published var tasks: [Task] = [] {
        willSet {
            selectedCategory = nil
            incompleteTasks = newValue.filter { !$0.isCompleted }
            completeTasks = newValue.filter { $0.isCompleted }.reversed()
        }
    }
    @Published var selectedCategory: TaskCategory? {
        willSet {
            if let category = newValue {
                incompleteTasks = tasks.filter { !$0.isCompleted && $0.category == category }
            } else {
                incompleteTasks = tasks.filter { !$0.isCompleted }
            }
        }
    }
    
    var subTaskStorage = SubtaskStorage.shared
    var taskStorage = TaskStorage.shared
    
    private var taskCancellable: AnyCancellable?
    
    private init(taskPublisher: AnyPublisher<[Task], Never> = TaskStorage.shared.tasks.eraseToAnyPublisher()) {
        taskCancellable = taskPublisher.sink { tasks in
            print("Updating tasks...")
            self.tasks = tasks
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func filterTasks(_ tasks: [Task], by searchValue: String) -> [Task]? {
        var filtered: [Task]?
        if searchValue != "" {
            filtered = tasks.filter { task in
                let upperSearch = searchValue.uppercased()
                let titleContainsValue = task.taskTitle!.uppercased().contains(upperSearch)
                let descContainsValue = task.taskDescription?.uppercased().contains(upperSearch) ?? false
                let hasMatchingSubTask = task.subTaskArray.contains { $0.wrappedTitle.uppercased().contains(upperSearch) }
                return titleContainsValue || descContainsValue || hasMatchingSubTask
            }
        }
        return filtered
    }
}
