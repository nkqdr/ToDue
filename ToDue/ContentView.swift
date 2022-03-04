//
//  ContentView.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

struct ContentView: View {
    let coreDM: CoreDateManager
    @State private var taskDescription = ""
    @State private var date = Date.now
    @State private var taskArray = [Task]()
    
    var body: some View {
        VStack(spacing: 15) {
            TextField("Please enter a description...", text: $taskDescription)
            DatePicker("Pick a due date:", selection: $date)
            Button("Save") {
                coreDM.saveTask(taskDescription: taskDescription, date: date)
                displayTasks()
                taskDescription = ""
                date = Date.now
            }
            List {
                ForEach(taskArray, id: \.self) { task in
                    VStack {
                        Text(task.taskDescription ?? "")
                        Text(task.date != nil ? task.date!.description : "")
                    }
                }.onDelete(perform: { indexSet in
                    indexSet.forEach {index in
                        let task = taskArray[index]
                        coreDM.deleteTask(task: task)
                        displayTasks()
                    }
                })
            }
        }
        .padding()
        .onAppear(perform: {
            displayTasks()
        })
    }
    
    func displayTasks() {
        taskArray = coreDM.getAllTasks()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(coreDM: CoreDateManager())
    }
}
