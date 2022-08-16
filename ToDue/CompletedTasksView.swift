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
                ScrollView {
                    ForEach (taskManager.completeTasks) { task in
                        TaskContainer(namespace: taskNamespace, task: task)
                    }
                    .animation(.spring(), value: taskManager.completeTasks)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
            .navigationTitle("Completed")
        }
        .navigationViewStyle(.stack)
    }
}
