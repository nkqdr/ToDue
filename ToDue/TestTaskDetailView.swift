//
//  TaskDetailView.swift
//  ToDue
//
//  Created by Niklas Kuder on 17.08.22.
//

import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State var showAddSubtaskSheet: Bool = false
    var task: Task
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                Group {
                    dueDate
                    if !taskManager.currentSubTaskArray.isEmpty {
                        ProgressBar(progress: taskManager.progress(for: task))
                            .padding(.bottom, 20)
                    }
                    subTasksHeader
                    subTasksList
                    Spacer(minLength: 50)
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .background(Color("Background"))
        }
        .navigationTitle(task.taskDescription ?? "")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO: Implement edit functionality
    //                            coreDM.removeAllSubTasks(from: task)
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showAddSubtaskSheet) {
            AddSubtaskView(isPresented: $showAddSubtaskSheet)
            // Once iOS 16 is out, use .presentationDetents here!
        }
    }
    
    @ViewBuilder
    var subTasksList: some View {
        let task = taskManager.currentTask!
        ForEach(taskManager.currentSubTaskArray) { subTask in
            HStack {
                Text(subTask.title!)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
                Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .padding(.trailing)
                    .onTapGesture {
                        Haptics.shared.play(.medium)
                        task.objectWillChange.send()
                        taskManager.toggleCompleted(subTask)
                    }
            }
            .background(RoundedRectangle(cornerRadius: 15).fill(Color("Accent1")))
            .frame(maxWidth: .infinity, alignment: .leading)
         
        }
    }
    
    var subTasksHeader: some View {
        HStack (alignment: .bottom) {
            Text("Sub-Tasks:")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Spacer()
            Button {
                showAddSubtaskSheet.toggle()
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
    }
    
    var dueDate: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        return HStack {
            Text("Due: " + dateFormatter.string(from: task.date ?? Date.now))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.bottom, 20)
    }
}
