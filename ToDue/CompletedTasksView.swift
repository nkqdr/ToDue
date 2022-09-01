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
                    ForEach (displayedTasks ?? taskManager.completeTasks.map { $0 }) { task in
                        NavigationLink(destination: {
                            TaskDetailView(task: task)
                        }, label: {
                            TaskContainer(task: task)
                        })
                    }
                    .animation(.spring(), value: taskManager.completeTasks)
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
            .navigationTitle("Completed")
            .searchable(text: $searchValue)
            .onChange(of: searchValue) { newValue in
                DispatchQueue.global(qos: .userInitiated).async {
                    let newTasks = taskManager.filterTasks(taskManager.completeTasks.map { $0 }, by: searchValue)
                    DispatchQueue.main.async {
                        displayedTasks = newTasks
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
