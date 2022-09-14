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
    @State private var currentSubTask: SubTask?
    var task: Task
    
    var body: some View {
        List {
            Group {
                VStack(alignment: .leading) {
                    dueDate
                    taskDesc
                    if !task.subTaskArray.isEmpty {
                        ProgressBar(progress: taskManager.progress(for: task))
                            .padding(.bottom, DrawingConstants.progressBarPadding)
                    }
                }
                .listRowBackground(Color("Background"))
                .listRowInsets(EdgeInsets())
                subTaskList
                addSubTaskButton
            }
            .themedListRowBackground()
        }
        .background(Color("Background"))
        .confirmationDialog(
            Text("Are you sure you want to delete this?"),
            isPresented: $showingAlert,
            titleVisibility: .visible
        ) {
             Button("Delete", role: .destructive) {
                 withAnimation(.easeInOut) {
                     taskManager.deleteTask(currentSubTask!)
                 }
             }
            Button("Cancel", role: .cancel) {
                showingAlert = false
                currentSubTask = nil
            }
        } message: {
            Text(currentSubTask?.wrappedTitle ?? "")
                .font(.headline).fontWeight(.bold)
        }
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showEditTaskSheet = true
                } label: {
                    Image(systemName: "pencil")
                }
            }
        }
        .navigationTitle(task.taskTitle ?? "")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddSubtaskSheet, onDismiss: {
            currentSubTask = nil
        }) {
            AddSubtaskView(isPresented: $showAddSubtaskSheet, subtaskEditor: SubtaskEditor(currentSubTask, on: task))
                .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showEditTaskSheet) {
            AddTaskView(isPresented: $showEditTaskSheet, taskEditor: TaskEditor(task: task))
        }
    }
    
    private func editSubTaskButton(_ subTask: SubTask) -> some View {
        Button {
            currentSubTask = subTask
            showAddSubtaskSheet.toggle()
        } label: {
            Label("Edit", systemImage: "pencil")
        }
    }
    
    private func deleteSubTaskButton(_ subTask: SubTask) -> some View {
        Button(action: {
            currentSubTask = subTask
            showingAlert = true
        }, label: {
            Label("Delete", systemImage: "trash")
        })
        .tint(.red)
    }
    
    var addSubTaskButton: some View {
        HStack {
            Spacer()
            Button("Add subtask") {
                showAddSubtaskSheet.toggle()
            }
            Spacer()
        }
    }
    
    @ViewBuilder
    var dueDate: some View {
        if let date = task.date, date < Date.distantFuture {
            Text("Due: \(Utils.dateFormatter.string(from: task.date ?? Date.now))", comment: "Label in detail view that displays when this task is due.")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.bottom, DrawingConstants.dueDatePadding)
        }
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
    
    @ViewBuilder
    var subTaskList: some View {
        let subTaskArray = task.subTaskArray
        if !subTaskArray.isEmpty {
            let incomplete = subTaskArray.filter { !$0.isCompleted }
            if !incomplete.isEmpty {
                Section("Sub-Tasks") {
                    ForEach(incomplete) { subTask in
                        SubtaskView(subTask: subTask)
                            .swipeActions(edge: .trailing) {
                                deleteSubTaskButton(subTask)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    taskManager.toggleCompleted(subTask)
                                } label: {
                                    Label(subTask.isCompleted ? "Mark as incomplete" : "Mark as complete", systemImage: subTask.isCompleted ? "gobackward.minus" : "checkmark.circle.fill")
                                }
                                    .tint(.mint)
                                editSubTaskButton(subTask)
                                .tint(.indigo)
                            }
                            .contextMenu {
                                editSubTaskButton(subTask)
                                Button(role: .destructive, action: {
                                    currentSubTask = subTask
                                    showingAlert = true
                                }, label: {
                                    Label("Delete", systemImage: "trash")
                                })
                            }
                    }
                }
            }
            let completed = subTaskArray.filter { $0.isCompleted }
            if !completed.isEmpty {
                Section("Completed") {
                    ForEach(completed) { subTask in
                        SubtaskView(subTask: subTask)
                            .swipeActions(edge: .trailing) {
                                deleteSubTaskButton(subTask)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    taskManager.toggleCompleted(subTask)
                                } label: {
                                    Label(subTask.isCompleted ? "Mark as incomplete" : "Mark as complete", systemImage: subTask.isCompleted ? "gobackward.minus" : "checkmark.circle.fill")
                                }
                                    .tint(.mint)
                                editSubTaskButton(subTask)
                                .tint(.indigo)
                            }
                            .contextMenu {
                                editSubTaskButton(subTask)
                                Button(role: .destructive, action: {
                                    currentSubTask = subTask
                                    showingAlert = true
                                }, label: {
                                    Label("Delete", systemImage: "trash")
                                })
                            }
                    }
                }
            }
        } else {
            // Empty section here for some extra padding
            Section {}
        }
    }
    
    private struct DrawingConstants {
        static let dueDatePadding: CGFloat = 20
        static let subTaskCornerRadius: CGFloat = 10
        static let completeIndicatorSize: CGFloat = 50
        static let scrollBottomPadding: CGFloat = 50
        static let progressBarPadding: CGFloat = 20
        static let subTaskListRowInsets: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
}
