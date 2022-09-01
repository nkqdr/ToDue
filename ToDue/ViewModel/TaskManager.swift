//
//  TaskManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 16.08.22.
//

import Foundation

class TaskManager: ObservableObject {
    let coreDM: CoreDataManager
    
    init() {
        let coreDM = CoreDataManager.shared
        self.coreDM = coreDM
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
        coreDM.updateTask(task: task, description: task.taskDescription!, title: task.taskTitle!, date: task.date!, isCompleted: !task.isCompleted)
    }
    
    func toggleCompleted(_ subTask: SubTask) {
        coreDM.toggleIsCompleted(for: subTask)
        self.objectWillChange.send()
    }
    
    func deleteTask(_ task: Task) {
        coreDM.deleteTask(task: task)
        self.objectWillChange.send()
    }
    
    func deleteTask(_ subTask: SubTask) {
        coreDM.deleteSubTask(subTask: subTask)
        self.objectWillChange.send()
    }
    
    func addNewTask(description: String, title: String, date: Date) {
        coreDM.saveTask(taskDescription: description, taskTitle: title, date: date)
        self.objectWillChange.send()
    }
    
    func addSubTask(to task: Task, description: String) {
        coreDM.addSubTask(to: task, subTaskTitle: description)
        self.objectWillChange.send()
    }
    
    func editSubTask(_ subTask: SubTask, description: String) {
        coreDM.updateSubTask(subTask, description: description)
        self.objectWillChange.send()
    }
    
    func updateTask(_ task: Task, description: String?, title: String?, date: Date?, isCompleted: Bool?) {
        let newComplete: Bool = isCompleted ?? task.isCompleted
        let newDescription: String = description ?? task.taskDescription!
        let newTitle: String = title ?? task.taskTitle!
        let newDueDate: Date = date ?? task.date!
        coreDM.updateTask(task: task, description: newDescription, title: newTitle, date: newDueDate, isCompleted: newComplete)
        self.objectWillChange.send()
    }
}
