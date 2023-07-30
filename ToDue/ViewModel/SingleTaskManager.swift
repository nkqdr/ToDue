//
//  SingleTaskManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.06.23.
//

import Foundation
import Combine

class SingleTaskManager: ObservableObject, SubtaskModifier {
    var subTaskStorage = SubtaskStorage.main
    
    private var task: Task
    @Published var subTasks: [SubTask] = [] {
        didSet {
            self.progress = calculateProgress()
        }
    }
    @Published var progress: Double = 0
    
    private var subTaskCancellable: AnyCancellable?
    private(set) var subtaskFetchController: SubtaskFetchController
    
    init(task: Task) {
        self.task = task
        self.subtaskFetchController = SubtaskFetchController(task: task)
        
        let subTaskPublisher = self.subtaskFetchController.subTasks.eraseToAnyPublisher()
        self.subTaskCancellable = subTaskPublisher.sink { subTasks in
            print("Updating subtasks for single...")
            print(subTasks.count)
            self.subTasks = subTasks
        }
    }
    
    private func calculateProgress() -> Double {
        if subTasks.isEmpty {
            return task.isCompleted ? 1 : -1
        }
        let total: Int = task.subTaskArray.count
        let complete: Int = task.subTaskArray.filter {$0.isCompleted}.count
        return Double(complete) / Double(total)
    }
}
