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
    @State var showEditTaskSheet: Bool = false
    @State private var showingAlert: Bool = false
    @State private var subTaskToDelete: SubTask?
    var task: Task
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                Group {
                    VStack(alignment: .leading) {
                        dueDate
                        taskDesc
                        if !taskManager.currentSubTaskArray.isEmpty {
                            ProgressBar(progress: taskManager.progress(for: task))
                                .padding(.bottom, DrawingConstants.progressBarPadding)
                        }
                    }
                    .listRowBackground(Color("Background"))
                    .listRowInsets(EdgeInsets())
                    if !taskManager.currentSubTaskArray.isEmpty {
                        Section("Sub-Tasks") {
                            ForEach(taskManager.currentSubTaskArray) { subTask in
                                subTaskView(subTask)
                            }
                        }
                    } else {
                        Section {
                            ForEach(taskManager.currentSubTaskArray) { subTask in
                                subTaskView(subTask)
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        Button("Add a subtask") {
                            showAddSubtaskSheet.toggle()
                        }
                        Spacer()
                    }
                }
                .listRowBackground(Color("Accent2").opacity(0.3))
                .confirmationDialog(
                    Text("Are you sure you want to delete this?"),
                    isPresented: $showingAlert,
                    titleVisibility: .visible
                ) {
                     Button("Delete", role: .destructive) {
                         withAnimation(.easeInOut) {
                             taskManager.deleteTask(subTaskToDelete!)
                         }
                     }
                } message: {
                    Text(subTaskToDelete?.wrappedTitle ?? "")
                        .font(.headline).fontWeight(.bold)
                }
            }
            .background(Color("Background"))
        }
        .navigationTitle(task.taskTitle ?? "")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditTaskSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showAddSubtaskSheet) {
            AddSubtaskView(isPresented: $showAddSubtaskSheet)
            // TODO: Once iOS 16 is out, use .presentationDetents here!
        }
        .sheet(isPresented: $showEditTaskSheet) {
            AddTaskView(isPresented: $showEditTaskSheet, task: task)
        }
    }
    
    func subTaskView(_ subTask: SubTask) -> some View {
            HStack {
                Text(subTask.title ?? "")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .frame(width: DrawingConstants.completeIndicatorSize, height: DrawingConstants.completeIndicatorSize)
                    .onTapGesture {
                        Haptics.shared.play(.medium)
                        taskManager.toggleCompleted(subTask)
                    }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .swipeActions(edge: .trailing) {
                deleteSubTaskButton(subTask)
            }
            .swipeActions(edge: .leading) {
                toggleSubTaskCompleteButton(subTask)
                .tint(.indigo)
            }
//            .contextMenu {
//                toggleSubTaskCompleteButton(subTask)
//                deleteSubTaskButton(subTask)
//            }
//        }
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private func toggleSubTaskCompleteButton(_ subTask: SubTask) -> some View {
        Button {
            taskManager.toggleCompleted(subTask)
        } label: {
            Label(subTask.isCompleted ? "Mark as incomplete" : "Mark as complete", systemImage: subTask.isCompleted ? "gobackward.minus" : "checkmark.circle.fill")
        }
    }
    
    private func deleteSubTaskButton(_ subTask: SubTask) -> some View {
        Button(role: .destructive, action: {
            subTaskToDelete = subTask
            showingAlert = true
        }, label: {
            Label("Delete", systemImage: "trash")
        })
    }
    
    var dueDate: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        return Text("Due: \(dateFormatter.string(from: task.date ?? Date.now))", comment: "Label in detail view that displays when this task is due.")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .foregroundColor(.secondary)
            .padding(.bottom, DrawingConstants.dueDatePadding)
    }
    
    @ViewBuilder
    var taskDesc: some View {
        if let desc = task.taskDescription {
            if desc != "" {
                VStack(alignment: .leading) {
                    Text("Notes:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(desc)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private struct DrawingConstants {
        static let dueDatePadding: CGFloat = 20
        static let subTaskCornerRadius: CGFloat = 10
        static let completeIndicatorSize: CGFloat = 50
        static let scrollBottomPadding: CGFloat = 50
        static let progressBarPadding: CGFloat = 20
        static let subTaskBackgroundColor: Color = Color("Accent2").opacity(0.3)
    }
}
