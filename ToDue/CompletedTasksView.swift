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
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text("Total: \(taskManager.completeTasks.count)", comment: "Label that displays how many tasks have been completed in total.")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .foregroundColor(.green.opacity(0.8))
                    .padding(.horizontal)
                    ForEach (filteredTasks) { task in
                        NavigationLink(destination: {
                            TaskDetailView(task: task)
                        }, label: {
                            TaskContainer(task: task)
                        })
                        .simultaneousGesture(TapGesture().onEnded {
                            taskManager.currentTask = task
                        })                    }
                    .padding(.horizontal)
                    .animation(.spring(), value: filteredTasks)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
            .navigationTitle("Completed")
            .searchable(text: $searchValue)
        }
        .navigationViewStyle(.stack)
    }
    
    private var filteredTasks: [Task] {
        if searchValue == "" {
            return taskManager.completeTasks
        } else {
            let filteredTasks = taskManager.completeTasks.filter { task in
                let upperSearch = searchValue.uppercased()
                let titleContainsValue = task.taskTitle!.uppercased().contains(upperSearch)
                let descContainsValue = task.taskDescription?.uppercased().contains(upperSearch) ?? false
                let hasMatchingSubTask = task.subTaskArray.contains { $0.wrappedTitle.uppercased().contains(upperSearch) }
                return titleContainsValue || descContainsValue || hasMatchingSubTask
            }
            return filteredTasks
        }
    }
}
