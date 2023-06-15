//
//  SubtaskModifier.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.06.23.
//

import Foundation

protocol SubtaskModifier {
    var subTaskStorage: SubtaskStorage { get }
}

extension SubtaskModifier {
    func toggleCompleted(_ subTask: SubTask) {
        subTaskStorage.update(subTask, title: subTask.title, isCompleted: !subTask.isCompleted, scheduledDate: subTask.scheduledDate)
    }
    
    func delete(_ subTask: SubTask) {
        subTaskStorage.delete(subTask)
    }
    
    func scheduleForToday(_ subTask: SubTask) {
        let today: Date = Date()
        subTaskStorage.update(subTask, title: subTask.title, isCompleted: subTask.isCompleted, scheduledDate: today)
        ToastViewModel.shared.showSuccess(title: "Added", message: "Added to today's tasks!")
    }
    
    func unscheduleForToday(_ subTask: SubTask) {
        subTaskStorage.update(subTask, title: subTask.title, isCompleted: subTask.isCompleted, scheduledDate: nil)
        ToastViewModel.shared.showSuccess(title: "Removed", message: "Removed from today's tasks.")
    }
    
    func save(_ editor: SubtaskEditor) {
        let scheduledDate: Date? = editor.isScheduled ? editor.scheduledDate : nil
        if let st = editor.subtask {
            subTaskStorage.update(st, title: editor.subtaskTitle, isCompleted: st.isCompleted, scheduledDate: scheduledDate)
            return
        }
        if let task = editor.task {
            subTaskStorage.add(to: task, title: editor.subtaskTitle, scheduledDate: scheduledDate)
        } else {
            subTaskStorage.add(on: Date(), title: editor.subtaskTitle)
        }
        ToastViewModel.shared.showSuccess(title: "Created", message: "\(editor.subtaskTitle)")
    }
}
