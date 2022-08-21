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
    
    var remainingTime: String {
        if (incompleteTasks.isEmpty) {
            return "No Tasks!"
        }
        let diff = Calendar.current.dateComponents([.year, .month, .day], from: Date.now.removeTimeStamp!, to: incompleteTasks[0].date!)
        var outputStr = ""
        if (diff.year != nil && diff.year != 0) {
            outputStr += "\(diff.year!) "
            outputStr += diff.year == 1 ? "Year " : "Years "
        }
        if (diff.month != nil && diff.month != 0) {
            outputStr += "\(diff.month!) "
            outputStr += diff.month == 1 ? "Month " : "Months "
        }
        outputStr += "\(diff.day != nil ? diff.day! : 0) "
        outputStr += diff.day != nil && diff.day! == 1 ? "Day" : "Days"
        if (diff.day != nil && diff.month != nil && diff.year != nil && diff.day! < 0 && diff.month! <= 0 && diff.year! <= 0) {
            return "Task is past due!"
        } else {
            return outputStr
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
    
    // MARK: - Intents
    
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
        print("Deleting \(subTask)")
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
    
    func updateTask(_ task: Task, description: String?, title: String?, date: Date?, isCompleted: Bool?) {
        let newComplete: Bool = isCompleted ?? task.isCompleted
        let newDescription: String = description ?? task.taskDescription!
        let newTitle: String = title ?? task.taskTitle!
        let newDueDate: Date = date ?? task.date!
        coreDM.updateTask(task: task, description: newDescription, title: newTitle, date: newDueDate, isCompleted: newComplete)
        self.update()
    }
}
