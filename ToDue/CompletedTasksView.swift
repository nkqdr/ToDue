//
//  CompletedTasksView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    
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
                    ForEach (taskManager.completeTasks) { task in
                        NavigationLink(destination: {
                            TaskDetailView(task: task)
                        }, label: {
                            TaskContainer(task: task)
                        })
                        .simultaneousGesture(TapGesture().onEnded {
                            taskManager.currentTask = task
                        })
                    }
                    .padding(.horizontal)
                    .animation(.spring(), value: taskManager.completeTasks)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
            .navigationTitle("Completed")
        }
        .navigationViewStyle(.stack)
    }
}
