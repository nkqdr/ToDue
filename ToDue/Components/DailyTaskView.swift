//
//  DailyTaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.02.23.
//

import SwiftUI

struct DailyTaskView: View {
    @ObservedObject private var dailyManager = DailyTaskManager()
    private var taskDueDate: Date = Date()
    private var taskTitle: LocalizedStringKey = "Daily Task"
    
    private var showDailyTask: Bool {
        !(dailyManager.subTasks.isEmpty && dailyManager.tasks.isEmpty)
    }
    
    var listContainer: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DrawingConstants.containerCornerRadius)
                .fill(dailyManager.progress < 1 ? DrawingConstants.defaultTaskBackgroundColor : .green.opacity(0.5))
            HStack {
                VStack(alignment: .leading) {
                    Text(Utils.dateFormatter.string(from: taskDueDate))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(taskTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                        .foregroundColor(Color("Text"))
                    Spacer()
                }
                .multilineTextAlignment(.leading)
                .padding()
                Spacer()
                ProgressCircle(isCompleted: dailyManager.progress == 1, progress: dailyManager.progress) {
                    
                }
                .padding(.trailing)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .animation(.spring(), value: showDailyTask)
    }
    
    var detailView: some View {
        List {
            Group {
                VStack(alignment: .leading) {
                    dueDate
                    ProgressBar(progress: dailyManager.progress)
                        .padding(.bottom, DrawingConstants.progressBarPadding)
                }
                .listRowBackground(Color("Background"))
                .listRowInsets(EdgeInsets())
                subTaskList
            }
            .themedListRowBackground()
        }
        .groupListStyleIfNecessary()
        .background(Color("Background").ignoresSafeArea())
        .hideScrollContentBackgroundIfNecessary()
        .navigationTitle(taskTitle)
        .navigationBarTitleDisplayMode(.large)
        .listStyle(.sidebar)
    }
    
    var body: some View {
        if showDailyTask {
            NavigationLink(destination: {
                detailView
            }, label: {
                listContainer
            })
        } else {
            EmptyView()
        }
    }
    
    var dueDate: some View {
        Text("Due: \(Utils.dateFormatter.string(from: taskDueDate))", comment: "Label in detail view that displays when this task is due.")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .foregroundColor(.secondary)
    }
    
    func subTaskList(_ subTasks: [SubTask]) -> some View {
        ForEach(subTasks) { subTask in
            SubtaskContainer(title: subTask.title ?? "", isCompleted: subTask.isCompleted) {
                Haptics.shared.play(.medium)
                dailyManager.toggleCompleted(subTask)
            }
        }
    }
    
    @ViewBuilder
    var subTaskList: some View {
        let subTaskArray = dailyManager.subTasks
        if !subTaskArray.isEmpty {
            let incomplete = subTaskArray.filter { !$0.isCompleted }
            if !incomplete.isEmpty {
                Section(header: Text("Open")) {
                    subTaskList(incomplete)
                }
            }
            let completed = subTaskArray.filter { $0.isCompleted }
            if !completed.isEmpty {
                Section(header: Text("Completed")) {
                    subTaskList(completed)
                }
            }
        } else {
            // Empty section here for some extra padding
            Section {}
        }
    }
    
    private struct DrawingConstants {
        static let topTaskBackgroundColor: Color = Color("Accent1")
        static let defaultTaskBackgroundColor: Color = Color("Accent2").opacity(0.3)
        static let completeTaskBackgroundColor: Color = Color.green.opacity(0.5)
        static let topTaskMinHeight: CGFloat = 140
        static let containerCornerRadius: CGFloat = 12
        static let progressBarPadding: CGFloat = 20
    }
}

struct DailyTaskView_Previews: PreviewProvider {
    static var previews: some View {
        DailyTaskView()
    }
}
