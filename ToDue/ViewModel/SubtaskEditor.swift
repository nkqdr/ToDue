//
//  SubtaskEditor.swift
//  ToDue
//
//  Created by Niklas Kuder on 31.08.22.
//

import Foundation

class SubtaskEditor: ObservableObject {
    private(set) var subtask: SubTask?
    private(set) var task: Task
    
    @Published var subtaskTitle: String
    
    init(_ subtask: SubTask?, on task: Task) {
        self.subtask = subtask
        self.subtaskTitle = subtask?.title ?? ""
        self.task = task
    }
    
    init(on task: Task) {
        self.subtaskTitle = ""
        self.task = task
    }
}
