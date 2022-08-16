//
//  CompletedTasksView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    var taskNamespace: Namespace.ID
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    HStack {
                        Text("Total: \(taskManager.completeTasks.count)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .foregroundColor(.green.opacity(0.8))
                    .padding(.horizontal)
                    ForEach (taskManager.completeTasks) { task in
                        TaskContainer(namespace: taskNamespace, task: task)
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
