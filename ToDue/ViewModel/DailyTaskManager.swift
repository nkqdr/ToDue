//
//  DailyTaskManager.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.02.23.
//

import Foundation
import Combine
import WidgetKit

class DailyTaskManager: ObservableObject {
    
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
    
    private var taskCancellable: AnyCancellable?
    private var subTaskCancellable: AnyCancellable?
    
    init(taskPublisher: AnyPublisher<[Task], Never> = TaskStorage.shared.tasks.eraseToAnyPublisher(),
         subTaskPublisher: AnyPublisher<[SubTask], Never> = SubtaskStorage.shared.subTasks.eraseToAnyPublisher()) {
        let today: Date = Date()
        
        taskCancellable = taskPublisher.sink { tasks in
            self.tasks = tasks.filter({ $0.dailyTask?.isSameDayAs(today) ?? false })
        }
        subTaskCancellable = subTaskPublisher.sink { subTasks in
            self.subTasks = subTasks.filter({ $0.dailyTask?.isSameDayAs(today) ?? false })
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
    
    func toggleCompleted(_ task: Task) {
        if task.isCompleted {
            // Task will now be incomplete
            Utils.scheduleNewNotification(for: task)
        } else {
            // Task will now be complete
            Utils.cancelNotification(for: task)
        }
        TaskStorage.shared.toggleCompleted(for: task)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func toggleCompleted(_ subTask: SubTask) {
        SubtaskStorage.shared.update(subTask, title: subTask.title, isCompleted: !subTask.isCompleted)
    }
}
