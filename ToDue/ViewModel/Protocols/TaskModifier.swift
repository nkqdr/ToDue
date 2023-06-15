//
//  TaskModifier.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.06.23.
//

import Foundation
import WidgetKit

protocol TaskModifier {
    var taskStorage: TaskStorage { get }
}

extension TaskModifier {
    func toggleCompleted(_ task: Task) {
        if task.isCompleted {
            // Task will now be incomplete
            Utils.scheduleNewNotification(for: task)
        } else {
            // Task will now be complete
            Utils.cancelNotification(for: task)
        }
        taskStorage.toggleCompleted(for: task)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func delete(_ task: Task) {
        TaskStorage.shared.delete(task)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func save(_ editor: TaskEditor) {
        let newDate = editor.hasDeadline ? editor.taskDueDate.removeTimeStamp! : Date.distantFuture
        let newDescription = editor.taskDescription
        let newTitle = editor.taskTitle
        let scheduledDate: Date? = editor.isScheduled ? editor.scheduledDate : nil
        if let newTask = editor.task {
            taskStorage.update(newTask, title: newTitle, description: newDescription, date: newDate, isCompleted: newTask.isCompleted, category: editor.category, scheduledDate: scheduledDate)
        } else {
            let task = taskStorage.add(title: newTitle, description: newDescription, date: newDate, category: editor.category, scheduledDate: scheduledDate)
            Utils.scheduleNewNotification(for: task)
            ToastViewModel.shared.showSuccess(title: "Created", message: "\(editor.taskTitle)")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func scheduleForToday(_ task: Task) {
        let today: Date = Date()
        taskStorage.update(task, title: task.taskTitle, description: task.taskDescription, date: task.date, isCompleted: task.isCompleted, category: task.category, scheduledDate: today)
        ToastViewModel.shared.showSuccess(title: "Added", message: "Added to today's tasks!")
    }
    
    func unscheduleForToday(_ task: Task) {
        taskStorage.update(task, title: task.taskTitle, description: task.taskDescription, date: task.date, isCompleted: task.isCompleted, category: task.category, scheduledDate: nil)
        ToastViewModel.shared.showSuccess(title: "Removed", message: "Removed from today's tasks.")
    }
}
