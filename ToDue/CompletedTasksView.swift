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
//    @State private var showDeadlineTasks: Bool = true
//    
//    private func filterTasksByDeadline(newValue: Bool) {
//        if newValue {
//            displayedTasks = taskManager.completeTasks.filter {$0.wrappedDate != Date.distantFuture}
//        } else {
//            displayedTasks = taskManager.completeTasks.filter {$0.wrappedDate == Date.distantFuture}
//        }
//    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                HStack {
                    Text("Total: \(taskManager.completeTasks.count)", comment: "Label that displays how many tasks have been completed in total.")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .foregroundColor(.green.opacity(0.8))
                .padding(.horizontal)
//                Picker("Task type", selection: $showDeadlineTasks) {
//                    Text("Deadline").tag(true)
//                    Text("No Deadline").tag(false)
//                }
//                .pickerStyle(.segmented)
//                .padding(.horizontal)
//                .onChange(of: showDeadlineTasks, perform: filterTasksByDeadline)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Completed")
            .versionAwareSearchable(text: $searchValue)
            .onChange(of: searchValue) { newValue in
                DispatchQueue.global(qos: .userInitiated).async {
                    let newTasks = taskManager.filterTasks(taskManager.completeTasks.map { $0 }, by: searchValue)
                    DispatchQueue.main.async {
                        displayedTasks = newTasks
                    }
                }
            }
            if let task = taskManager.completeTasks.first {
                TaskDetailView(task: task)
            } else {
                ZStack {
                    Color("Background")
                        .ignoresSafeArea()
                    Text("Open the sidebar to create a new task!")
                        .font(.headline)
                        .foregroundColor(Color("Text"))
                }
            }
        }
        .currentDeviceNavigationViewStyle()
    }
}

struct CompletedTasksView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedTasksView()
            .environmentObject(TaskManager.shared)
    }
}
