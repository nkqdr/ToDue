//
//  TaskManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 16.08.22.
//

import Foundation
import WidgetKit
import Combine

class TaskManager: ObservableObject {
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
    
    private var taskCancellable: AnyCancellable?
    private var subTaskCancellable: AnyCancellable?
    
    private init(taskPublisher: AnyPublisher<[Task], Never> = TaskStorage.shared.tasks.eraseToAnyPublisher(),
         subTaskPublisher: AnyPublisher<[SubTask], Never> = SubtaskStorage.shared.subTasks.eraseToAnyPublisher()) {
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
    
    // MARK: - Intents
    
    func toggleCompleted(_ task: Task) {
        if task.isCompleted {
            // Task will now be incomplete
            Utils.scheduleNewNotification(for: task)
        } else {
            // Task will now be complete
            Utils.cancelNotification(for: task)
        }
        TaskStorage.shared.toggleCompleted(for: task)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func toggleCompleted(_ subTask: SubTask) {
        SubtaskStorage.shared.update(subTask, title: subTask.title, isCompleted: !subTask.isCompleted, scheduledDate: subTask.scheduledDate)
    }
    
    func deleteTask(_ task: Task) {
        TaskStorage.shared.delete(task)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func deleteTask(_ subTask: SubTask) {
        SubtaskStorage.shared.delete(subTask)
    }
    
    func saveSubtask(_ editor: SubtaskEditor) {
        let scheduledDate: Date? = editor.isScheduled ? editor.scheduledDate : nil
        if let st = editor.subtask {
            SubtaskStorage.shared.update(st, title: editor.subtaskTitle, isCompleted: st.isCompleted, scheduledDate: scheduledDate)
            return
        }
        if let task = editor.task {
            SubtaskStorage.shared.add(to: task, title: editor.subtaskTitle, scheduledDate: scheduledDate)
        } else {
            SubtaskStorage.shared.add(on: Date(), title: editor.subtaskTitle)
        }
        ToastViewModel.shared.showSuccess(title: "Created", message: "\(editor.subtaskTitle)")
    }
    
    func saveTask(_ editor: TaskEditor) {
        let newDate = editor.hasDeadline ? editor.taskDueDate.removeTimeStamp! : Date.distantFuture
        let newDescription = editor.taskDescription
        let newTitle = editor.taskTitle
        let scheduledDate: Date? = editor.isScheduled ? editor.scheduledDate : nil
        if let newTask = editor.task {
            TaskStorage.shared.update(newTask, title: newTitle, description: newDescription, date: newDate, isCompleted: newTask.isCompleted, category: editor.category, scheduledDate: scheduledDate)
        } else {
            let task = TaskStorage.shared.add(title: newTitle, description: newDescription, date: newDate, category: editor.category, scheduledDate: scheduledDate)
            Utils.scheduleNewNotification(for: task)
            ToastViewModel.shared.showSuccess(title: "Created", message: "\(editor.taskTitle)")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func scheduleForToday(_ subTask: SubTask) {
        let today: Date = Date()
        SubtaskStorage.shared.update(subTask, title: subTask.title, isCompleted: subTask.isCompleted, scheduledDate: today)
        ToastViewModel.shared.showSuccess(title: "Added", message: "Added to today's tasks!")
    }
    
    func unscheduleForToday(_ subTask: SubTask) {
        SubtaskStorage.shared.update(subTask, title: subTask.title, isCompleted: subTask.isCompleted, scheduledDate: nil)
        ToastViewModel.shared.showSuccess(title: "Removed", message: "Removed from today's tasks.")
    }
    
    func scheduleForToday(_ task: Task) {
        let today: Date = Date()
        TaskStorage.shared.update(task, title: task.taskTitle, description: task.taskDescription, date: task.date, isCompleted: task.isCompleted, category: task.category, scheduledDate: today)
        ToastViewModel.shared.showSuccess(title: "Added", message: "Added to today's tasks!")
    }
    
    func unscheduleForToday(_ task: Task) {
        TaskStorage.shared.update(task, title: task.taskTitle, description: task.taskDescription, date: task.date, isCompleted: task.isCompleted, category: task.category, scheduledDate: nil)
        ToastViewModel.shared.showSuccess(title: "Removed", message: "Removed from today's tasks.")
    }
}
