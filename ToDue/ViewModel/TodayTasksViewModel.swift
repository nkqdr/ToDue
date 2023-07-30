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
    private(set) var subTaskStorage: SubtaskStorage = SubtaskStorage.shared
    
    private var taskCancellable: AnyCancellable?
    private var subTaskCancellable: AnyCancellable?
    
    init() {
        let today: Date = Date()
        let taskFetchController = TaskFetchController.all
        let taskPublisher = taskFetchController.tasks.eraseToAnyPublisher()
        let subTaskPublisher = subTaskStorage.subTasks.eraseToAnyPublisher()
        
        taskCancellable = taskPublisher.sink { tasks in
            self.tasks = tasks.filter({ $0.scheduledDate?.isSameDayAs(today) ?? false })
        }
        subTaskCancellable = subTaskPublisher.sink { subTasks in
            self.subTasks = subTasks.filter({ $0.scheduledDate?.isSameDayAs(today) ?? false })
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
}
