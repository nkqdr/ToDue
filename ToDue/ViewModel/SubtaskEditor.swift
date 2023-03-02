//
//  SubtaskEditor.swift
//  ToDue
//
//  Created by Niklas Kuder on 31.08.22.
//

import Foundation

/// This class is used as a controller for editing and creating subtasks
class SubtaskEditor: ObservableObject {
    private(set) var subtask: SubTask?
    private(set) var task: Task?
    
    @Published var subtaskTitle: String
    @Published var saveButtonDisabled: Bool = true
    @Published var isScheduled: Bool
    @Published var scheduledDate: Date
    @Published var disableScheduling: Bool = false
    
    init(_ subtask: SubTask?, on task: Task) {
        self.subtask = subtask
        self.subtaskTitle = subtask?.title ?? ""
        self.isScheduled = subtask?.scheduledDate != nil
        self.scheduledDate = subtask?.scheduledDate ?? Date()
        self.task = task
    }
    
    init(_ subtask: SubTask?, scheduled: Date) {
        self.subtask = subtask
        self.subtaskTitle = subtask?.title ?? ""
        self.isScheduled = true
        self.scheduledDate = scheduled
        self.disableScheduling = true
    }
    
    init(on task: Task) {
        self.subtaskTitle = ""
        self.task = task
        self.isScheduled = false
        self.scheduledDate = Date()
    }
    
    // MARK: - Intents
    
    func changeTitleValue(newValue: String) {
        if (newValue.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
            saveButtonDisabled = false
        } else {
            saveButtonDisabled = true
        }
    }
}
