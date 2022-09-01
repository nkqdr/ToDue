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
    @Published private(set) var container = CoreDataManager.shared.persistentContainer
    
    @Published var incompleteTasks: [Task] = []
    @Published var completeTasks: [Task] = []
    @Published var tasks: [Task] = [] {
        willSet {
            print("Setting tasks...")
            incompleteTasks = newValue.filter { !$0.isCompleted }
            completeTasks = newValue.filter { $0.isCompleted }.reversed()
        }
    }
    
    private var cancellable: AnyCancellable?
    
    init(taskPublisher: AnyPublisher<[Task], Never> = TaskStorage.shared.tasks.eraseToAnyPublisher()) {
        cancellable = taskPublisher.sink { tasks in
            print("Updating tasks...")
            self.tasks = tasks
        }
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
    
    // MARK: - Private utility functions
    
    private func addSubTask(to task: Task, description: String) {
        let subTask = SubTask(context: container.viewContext)
        subTask.title = description
        subTask.id = UUID()
        subTask.isCompleted = false
        subTask.createdAt = Date.now
        
        task.addToSubTasks(subTask)
        try? container.viewContext.save()
    }
    
    private func editSubTask(_ subTask: SubTask, description: String) {
        container.viewContext.performAndWait {
            subTask.title = description
            try? container.viewContext.save()
        }
    }
    
    private func updateTask(_ task: Task, description: String?, title: String?, date: Date?, isCompleted: Bool?) {
        TaskStorage.shared.update(task, title: title, description: description, date: date, isCompleted: isCompleted)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func addNewTask(description: String, title: String, date: Date) {
        TaskStorage.shared.add(title: title, description: description, date: date)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func saveOrRollback() {
        do {
            try container.viewContext.save()
        } catch {
            container.viewContext.rollback()
            print("Failed to save context \(error.localizedDescription)")
        }
    }
    
    // MARK: - Intents
    
    func toggleCompleted(_ task: Task) {
        container.viewContext.performAndWait {
            task.isCompleted = !task.isCompleted
            try? container.viewContext.save()
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func toggleCompleted(_ subTask: SubTask) {
        subTask.isCompleted.toggle()
        try? container.viewContext.save()
        self.objectWillChange.send()
    }
    
    func deleteTask(_ task: Task) {
        TaskStorage.shared.delete(task)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func deleteTask(_ subTask: SubTask) {
        container.viewContext.delete(subTask)
        saveOrRollback()
    }
    
    func saveSubtask(_ editor: SubtaskEditor) {
        if let st = editor.subtask {
            editSubTask(st, description: editor.subtaskTitle)
        } else {
            addSubTask(to: editor.task, description: editor.subtaskTitle)
        }
        self.objectWillChange.send()
    }
    
    func saveTask(_ editor: TaskEditor) {
        let newDate = editor.taskDueDate.removeTimeStamp!
        let newDescription = editor.taskDescription
        let newTitle = editor.taskTitle
        if let newTask = editor.task {
            updateTask(newTask, description: newDescription, title: newTitle, date: newDate, isCompleted: newTask.isCompleted)
        } else {
            addNewTask(description: newDescription, title: newTitle, date: newDate)
        }
        self.objectWillChange.send()
    }
}
