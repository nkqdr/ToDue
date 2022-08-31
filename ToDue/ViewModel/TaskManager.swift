//
//  TaskManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 16.08.22.
//

import Foundation

class TaskManager: ObservableObject {
    private let coreDM: CoreDataManager
    @Published var taskArray: [Task] = []
    
    var incompleteTasks: [Task] {
        taskArray.filter { !$0.isCompleted }
    }
    
    var completeTasks: [Task] {
        taskArray.filter { $0.isCompleted }.sorted(by: { $0.date! > $1.date! })
    }
    
    @Published var filteredCompleteTasks: [Task]?
    
    var currentTask: Task?
    
    var currentSubTaskArray: [SubTask] {
        if let task = currentTask {
            return task.subTaskArray
        }
        return []
    }
    
    init() {
        let coreDM = CoreDataManager.shared
        self.coreDM = coreDM
        self.taskArray = coreDM.getAllTasks().sorted(by: { $0.date! < $1.date! })
    }
    
    private func update() {
        self.taskArray = coreDM.getAllTasks().sorted(by: { $0.date! < $1.date! })
    }
    
    var currentTaskProgress: Double {
        if let task = currentTask {
            return progress(for: task)
        }
        return -1
    }
    
    func progress(for task: Task) -> Double {
        if task.subTaskArray.isEmpty {
            return task.isCompleted ? 1 : -1
        }
        let total: Int = task.subTaskArray.count
        let complete: Int = task.subTaskArray.filter {$0.isCompleted}.count
        return Double(complete) / Double(total)
    }
    
    // MARK: - Intents
    
    func filterCompletedTasks(by searchValue: String) {
        if searchValue == "" {
            filteredCompleteTasks = nil
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                let filteredTasks = self.completeTasks.filter { task in
                    let upperSearch = searchValue.uppercased()
                    let titleContainsValue = task.taskTitle!.uppercased().contains(upperSearch)
                    let descContainsValue = task.taskDescription?.uppercased().contains(upperSearch) ?? false
                    let hasMatchingSubTask = task.subTaskArray.contains { $0.wrappedTitle.uppercased().contains(upperSearch) }
                    return titleContainsValue || descContainsValue || hasMatchingSubTask
                }
                DispatchQueue.main.async {
                    self.filteredCompleteTasks = filteredTasks
                }
            }
        }
    }
    
    func setCurrentTask(_ task: Task) {
        self.currentTask = task
    }
    
    func toggleCompleted(_ task: Task) {
        coreDM.updateTask(task: task, description: task.taskDescription!, title: task.taskTitle!, date: task.date!, isCompleted: !task.isCompleted)
        self.update()
    }
    
    func toggleCompleted(_ subTask: SubTask) {
        coreDM.toggleIsCompleted(for: subTask)
        self.update()
    }
    
    func deleteTask(_ task: Task) {
        coreDM.deleteTask(task: task)
        self.update()
    }
    
    func deleteTask(_ subTask: SubTask) {
        coreDM.deleteSubTask(subTask: subTask)
        self.update()
    }
    
    func addNewTask(description: String, title: String, date: Date) {
        coreDM.saveTask(taskDescription: description, taskTitle: title, date: date)
        self.update()
    }
    
    func addSubTask(to task: Task, description: String) {
        coreDM.addSubTask(to: task, subTaskTitle: description)
        self.update()
    }
    
    func editSubTask(_ subTask: SubTask, description: String) {
        coreDM.updateSubTask(subTask, description: description)
        self.update()
    }
    
    func updateTask(_ task: Task, description: String?, title: String?, date: Date?, isCompleted: Bool?) {
        let newComplete: Bool = isCompleted ?? task.isCompleted
        let newDescription: String = description ?? task.taskDescription!
        let newTitle: String = title ?? task.taskTitle!
        let newDueDate: Date = date ?? task.date!
        coreDM.updateTask(task: task, description: newDescription, title: newTitle, date: newDueDate, isCompleted: newComplete)
        self.update()
    }
}
