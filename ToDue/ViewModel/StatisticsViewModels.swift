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

class UpcomingTasksViewModel: ObservableObject {
    @Published var upcomingTasks: [Task] = [] {
        didSet {
            print(upcomingTasks.count)
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
        print(allDates.count)
        print(uniqueMonths.count)
        
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
