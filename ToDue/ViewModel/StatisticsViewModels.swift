//
//  StatisticsViewModels.swift
//  ToDue
//
//  Created by Niklas Kuder on 08.07.23.
//

import Foundation
import Combine

struct TimeValueDataPoint: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var value: Int
}

struct ValueCategoryDataPoint: Identifiable {
    var id: UUID = UUID()
    var category: TaskCategory
    var value: Int
}

class UpcomingTasksViewModel: ObservableObject {
    @Published var upcomingTasks: [Task] = [] {
        didSet {
            upcomingTaskData = createData()
        }
    }
    @Published var upcomingTaskData: [TimeValueDataPoint] = []
    
    private var taskCancellable: AnyCancellable?
    private let fetchController: TaskFetchController
    
    init() {
        let todayDate = Date()
        let todayInOneYearDate = Calendar.current.date(byAdding: DateComponents(year: 1), to: todayDate) ?? Date()
        self.fetchController = TaskFetchController(predicate: NSPredicate(format: "date >= %@ && date <= %@", todayDate as NSDate, todayInOneYearDate as NSDate))
        let publisher = fetchController.tasks.eraseToAnyPublisher()
        self.taskCancellable = publisher.sink { value in
            self.upcomingTasks = value
        }
    }
    
    private func createData() -> [TimeValueDataPoint] {
        let allDates = upcomingTasks.map { Calendar.current.dateComponents([.month, .year], from: $0.wrappedDate) }
        let uniqueMonths = Set(allDates)
        
        return uniqueMonths.map { uniqueMonth in
            return TimeValueDataPoint(
                date: Calendar.current.date(from: uniqueMonth) ?? Date(),
                value: upcomingTasks.filter {
                    Calendar.current.dateComponents([.month, .year], from: $0.wrappedDate) == uniqueMonth
                }.count
            )
        }
    }
}

class ThisMonthCompletedTasksViewModel: ObservableObject {
    @Published var completedTasks: [Task] = [] {
        didSet {
            completedTasksData = createData()
        }
    }
    @Published var completedTasksData: [TimeValueDataPoint] = []
    
    private var taskCancellable: AnyCancellable?
    private let fetchController: TaskFetchController
    
    init() {
        let date: Date = Date()
        let startOfMonth: Date = date.startOfThisMonth.removeTimeStamp!
        let endOfMonth: Date = Calendar.current.date(byAdding: DateComponents(month: 1), to: startOfMonth) ?? date
        self.fetchController = TaskFetchController(predicate: NSPredicate(format: "completedAt >= %@ && completedAt <= %@", startOfMonth as NSDate, endOfMonth as NSDate))
        let publisher = fetchController.tasks.eraseToAnyPublisher()
        self.taskCancellable = publisher.sink { value in
            self.completedTasks = value
        }
    }
    
    private func createData() -> [TimeValueDataPoint] {
        let allDates = completedTasks.map { Calendar.current.dateComponents([.day, .month, .year], from: $0.completedAt ?? Date()) }
        let uniqueDays = Set(allDates)
        
        return uniqueDays.map { uniqueDay in
            return TimeValueDataPoint(
                date: Calendar.current.date(from: uniqueDay) ?? Date(),
                value: completedTasks.filter {
                    Calendar.current.dateComponents([.day, .month, .year], from: $0.completedAt ?? Date()) == uniqueDay
                }.count
            )
        }
    }
}

class CompletedTasksByCategoryViewModel: ObservableObject {
    @Published var completedTasks: [Task] = [] {
        didSet {
            completedTasksData = createData()
        }
    }
    @Published var usedCategories: [TaskCategory] = [] {
        didSet {
            completedTasksData = createData()
        }
    }
    @Published var completedTasksData: [ValueCategoryDataPoint] = []
    
    private var taskCancellable: AnyCancellable?
    private var taskCategoryCancellable: AnyCancellable?
    private let fetchController: TaskFetchController
    private let categoryFetchController: TaskCategoryFetchController
    
    init() {
        self.fetchController = TaskFetchController(predicate: NSPredicate(format: "isCompleted == YES"))
        self.categoryFetchController = TaskCategoryFetchController(predicate: NSPredicate(format: "tasks.@count > 0"))
        let publisher = fetchController.tasks.eraseToAnyPublisher()
        let categoryPublisher = categoryFetchController.categories.eraseToAnyPublisher()
        self.taskCancellable = publisher.sink { value in
            self.completedTasks = value
        }
        self.taskCategoryCancellable = categoryPublisher.sink { value in
            self.usedCategories = value
        }
    }
    
    private func createData() -> [ValueCategoryDataPoint] {
        return self.usedCategories.map { category in
            return ValueCategoryDataPoint(
                category: category,
                value: completedTasks.filter { $0.category == category }.count
            )
        }
    }
}
