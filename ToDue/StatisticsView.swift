//
//  StatisticsView.swift
//  ToDue
//
//  Created by Niklas Kuder on 19.06.23.
//

import SwiftUI
import Charts

@available(iOS 16.0, *)
struct UpcomingTasksChart: View {
    @StateObject private var viewModel = UpcomingTasksViewModel()
    
    var body: some View {
        let barRadius: CGFloat = 24 / CGFloat(viewModel.upcomingTaskData.count)
        
        Chart(viewModel.upcomingTaskData) { dp in
            BarMark(x: .value("Month", dp.date, unit: .month), y: .value("# of deadlines", dp.value))
                .cornerRadius(barRadius)
                .annotation(position: .top) { _ in
                    Text("\(dp.value)")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                }
        }
        .chartYAxis(.hidden)
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
    }
}

@available(iOS 16.0, *)
struct ThisMonthCompletedTaskChart: View {
    @StateObject private var viewModel = ThisMonthCompletedTasksViewModel()
    
    var body: some View {
        let barRadius: CGFloat = 24 / CGFloat(viewModel.completedTasksData.count)
        
        Chart(viewModel.completedTasksData) { dp in
            BarMark(x: .value("Date", dp.date, unit: .day), y: .value("# of completed tasks", dp.value))
                .cornerRadius(barRadius)
                .annotation(position: .top) { _ in
                    Text("\(dp.value)")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                }
        }
        .chartYAxis(.hidden)
    }
}

@available(iOS 16.0, *)
struct StatisticsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    GroupBox("Upcoming deadlines") {
                       UpcomingTasksChart()
                    }
                    .groupBoxStyle(CustomGroupBox())
                    
                    GroupBox("Tasks completed this month") {
                       ThisMonthCompletedTaskChart()
                    }
                    .groupBoxStyle(CustomGroupBox())
                    
                    GroupBox("Completed tasks per category") {
                        
                    }
                    .groupBoxStyle(CustomGroupBox())
                }
                .padding()
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Statistics")
        }
        .currentDeviceNavigationViewStyle()
    }
}

fileprivate struct CustomGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            HStack {
                configuration.label
                    .font(.headline)
                Spacer()
            }
            configuration.content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color("Accent2").opacity(0.3))
        )
    }
}

@available(iOS 16.0, *)
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
