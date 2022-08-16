//
//  CompletedTasksView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject var taskManager: TaskManager
    var namespace: Namespace.ID
    @Binding var isPresented: Bool
    
    var body: some View {
        ScrollView {
            Group {
                HStack {
                    Text("Completed tasks")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    Button("Close") {
                        isPresented = false
                    }
                }
                .padding(.top)
                ForEach (taskManager.completeTasks) { task in
                    TaskContainer(namespace: namespace, task: task)
                }
                .animation(.spring(), value: taskManager.completeTasks)
            }
            .padding(.horizontal)
        }
        .background(Color("Background"))
    }
}
