//
//  CompletedTasksView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var searchValue = ""
    @State var displayedTasks: [Task]?
    
    @ViewBuilder
    private func taskSection(_ title: LocalizedStringKey, tasks: [Task]) -> some View {
        if !tasks.isEmpty {
            Section(header: Text(title)) {
                ForEach (tasks) { task in
                    ZStack {
                        TaskContainer(task: task, cornerRadius: 0)
                        NavigationLink(destination: TaskDetailView(task: task)) {
                            EmptyView()
                        }.opacity(0)
                    }
                }
                .animation(.spring(), value: taskManager.completeTasks)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    var body: some View {
        let deadlineTasksToShow: [Task] = displayedTasks?.filter({ $0.date != Date.distantFuture }) ?? taskManager.completeTasks.filter({ $0.date != Date.distantFuture })
        let taskWithoutDeadlineToShow: [Task] = displayedTasks?.filter({ $0.date == Date.distantFuture }) ?? taskManager.completeTasks.filter({ $0.date == Date.distantFuture })
        
        List {
            HStack {
                Text("Total: \(taskManager.completeTasks.count)", comment: "Label that displays how many tasks have been completed in total.")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .foregroundColor(.green.opacity(0.8))
            .listRowBackground(Color("Background"))
            .listRowInsets(EdgeInsets())
            taskSection("Deadline", tasks: deadlineTasksToShow)
            taskSection("No Deadline", tasks: taskWithoutDeadlineToShow)
        }
        .listStyle(.sidebar)
        .groupListStyleIfNecessary()
        .background(Color("Background").ignoresSafeArea())
        .navigationTitle("Archive")
        .hideScrollContentBackgroundIfNecessary()
        .versionAwareSearchable(text: $searchValue)
        .onChange(of: searchValue) { newValue in
            DispatchQueue.global(qos: .userInitiated).async {
                let newTasks = taskManager.filterTasks(taskManager.completeTasks.map { $0 }, by: searchValue)
                DispatchQueue.main.async {
                    displayedTasks = newTasks
                }
            }
        }
    }
}

struct CompletedTasksView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedTasksView()
            .environmentObject(TaskManager.shared)
    }
}
