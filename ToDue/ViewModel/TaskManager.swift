//
//  TaskManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 16.08.22.
//

import Foundation

class TaskManager: ObservableObject, SubtaskModifier, TaskModifier {
    static let shared: TaskManager = TaskManager()

    var subTaskStorage = SubtaskStorage.main
    var taskStorage = TaskStorage.main
}
