//
//  SubtaskEditor.swift
//  ToDue
//
//  Created by Niklas Kuder on 31.08.22.
//

import Foundation

class SubtaskEditor: ObservableObject {
    private(set) var subtask: SubTask?
    
    @Published var subtaskTitle: String
    
    init(_ subtask: SubTask?) {
        self.subtask = subtask
        self.subtaskTitle = subtask?.title ?? ""
    }
    
    init() {
        self.subtaskTitle = ""
    }
}
