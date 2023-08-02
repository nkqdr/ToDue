//
//  TodayTasksViewModel.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.02.23.
//

import Foundation
import Combine
import WidgetKit

class TodayTasksViewModel: ObservableObject, TaskModifier, SubtaskModifier {
    @Published var tasks: [Task] = [] {
        didSet {
            setProgress()
        }
    }
    @Published var subTasks: [SubTask] = [] {
        didSet {
            setProgress()
        }
    }
    @Published var progress: Double = 0
    var taskTitle: String = "Today"
    var taskDueDate: Date = Date()
    
    private(set) var taskStorage: TaskStorage = TaskStorage.main
    private(set) var subTaskStorage: SubtaskStorage = SubtaskStorage.main
    
    private var taskCancellable: AnyCancellable?
    private var subTaskCancellable: AnyCancellable?
    private var taskFetchController: TaskFetchController
    private var subtaskFetchController: SubtaskFetchController
    
    init() {
        let today: Date = Date()
        self.taskFetchController = TaskFetchController(scheduledAt: today)
        self.subtaskFetchController = SubtaskFetchController(scheduledAt: today)
        let taskPublisher = self.taskFetchController.tasks.eraseToAnyPublisher()
        let subTaskPublisher = self.subtaskFetchController.subTasks.eraseToAnyPublisher()

        taskCancellable = taskPublisher.sink { tasks in
            self.tasks = tasks
            print(tasks)
        }
        subTaskCancellable = subTaskPublisher.sink { subTasks in
            self.subTasks = subTasks
            print(subTasks)
        }
    }
    
    private func setupFetchControllers() {
        let today = Date()
        self.taskFetchController = TaskFetchController(scheduledAt: today)
        self.subtaskFetchController = SubtaskFetchController(scheduledAt: today)
        let taskPublisher = self.taskFetchController.tasks.eraseToAnyPublisher()
        let subTaskPublisher = self.subtaskFetchController.subTasks.eraseToAnyPublisher()
        taskCancellable = taskPublisher.sink { tasks in
            self.tasks = tasks
        }
        subTaskCancellable = subTaskPublisher.sink { subTasks in
            self.subTasks = subTasks
        }
    }
    
    private func setProgress() {
        if tasks.isEmpty && subTasks.isEmpty {
            progress = 1
        } else {
            let total: Int = tasks.count + subTasks.count
            let complete: Int = tasks.filter { $0.isCompleted }.count + subTasks.filter({ $0.isCompleted }).count
            progress = Double(complete) / Double(total)
        }
    }
    
    // MARK: - Intents
    
    public func refresh() {
        print("Refreshing")
        self.taskCancellable?.cancel()
        self.subTaskCancellable?.cancel()
        self.setupFetchControllers()
    }
}
