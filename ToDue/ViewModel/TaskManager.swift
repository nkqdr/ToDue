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
    
    @Published var subTasks: [SubTask] = []
    var subTaskStorage = SubtaskStorage.shared
    var taskStorage = TaskStorage.shared
    
    private var taskCancellable: AnyCancellable?
    private var subTaskCancellable: AnyCancellable?
    
    private init(taskPublisher: AnyPublisher<[Task], Never> = TaskStorage.shared.tasks.eraseToAnyPublisher()) {
        let subTaskPublisher = self.subTaskStorage.subTasks.eraseToAnyPublisher()
        taskCancellable = taskPublisher.sink { tasks in
            print("Updating tasks...")
            self.tasks = tasks
        }
        subTaskCancellable = subTaskPublisher.sink { subTasks in
            print("Updating subtasks...")
            self.subTasks = subTasks
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func progress(for task: Task) -> Double {
        if task.subTaskArray.isEmpty {
            return task.isCompleted ? 1 : -1
        }
        let total: Int = task.subTaskArray.count
        let complete: Int = task.subTaskArray.filter {$0.isCompleted}.count
        return Double(complete) / Double(total)
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
