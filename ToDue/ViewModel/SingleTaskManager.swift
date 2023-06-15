//
//  SingleTaskManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.06.23.
//

import Foundation
import Combine

class SingleTaskManager: ObservableObject, SubtaskModifier {
    private var task: Task
    @Published var subTasks: [SubTask] = []
    
    private var subTaskCancellable: AnyCancellable?
    var subTaskStorage: SubtaskStorage
    
    init(task: Task) {
        self.task = task
        
        let storage = SubtaskStorage(task: task)
        self.subTaskStorage = storage
        let subTaskPublisher = storage.subTasks.eraseToAnyPublisher()
        subTaskCancellable = subTaskPublisher.sink { subTasks in
            print("Updating subtasks for single...")
            print(subTasks.count)
            self.subTasks = subTasks
        }
    }
}
