//
//  CompletedTasksView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct CompletedTasksView: View {
    @EnvironmentObject var coreDM: CoreDataManager
    @Binding var isPresented: Bool
    @State private var taskArray = [Task]()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
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
                ForEach (taskArray) { task in
                    TaskContainer(task: task, geometry: geometry, showBackground: true, onUpdate: displayTasks)
                }
                .animation(.default, value: taskArray)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("Background"))
        .onAppear(perform: displayTasks)
    }
    
    func displayTasks() {
        var array = coreDM.getAllTasks()
        array = array.filter { task in
            task.isCompleted
        }
        array.sort {
            $0.date! < $1.date!
        }
        taskArray = array
    }
}
