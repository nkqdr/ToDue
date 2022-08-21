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
            ScrollView(showsIndicators: false) {
                Group {
                    dueDate
                    taskDesc
                    if !taskManager.currentSubTaskArray.isEmpty {
                        ProgressBar(progress: taskManager.progress(for: task))
                            .padding(.bottom, DrawingConstants.progressBarPadding)
                        subTasksHeader
                        subTasksList
                        Spacer(minLength: DrawingConstants.scrollBottomPadding)
                    } else {
                        GeometryReader { proxy in
                            VStack(alignment: .center) {
                                Spacer(minLength: UIScreen.main.bounds.size.height / 3)
                                Button("Add a subtask") {
                                    showAddSubtaskSheet.toggle()
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color("Background"))
        }
        .frame(maxWidth: .infinity)
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
    
    @ViewBuilder
    var subTasksList: some View {
        ForEach(taskManager.currentSubTaskArray) { subTask in
            HStack {
                Text(subTask.title!)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
                Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .frame(width: DrawingConstants.completeIndicatorSize, height: DrawingConstants.completeIndicatorSize)
                    .padding(.trailing)
                    .onTapGesture {
                        Haptics.shared.play(.medium)
                        taskManager.toggleCompleted(subTask)
                    }
            }
            .background(RoundedRectangle(cornerRadius: DrawingConstants.subTaskCornerRadius).fill(DrawingConstants.subTaskBackgroundColor))
            .frame(maxWidth: .infinity, alignment: .leading)
            .contextMenu(menuItems: {
                Button(role: .cancel, action: {
                    taskManager.toggleCompleted(subTask)
                }, label: {
                    Label(subTask.isCompleted ? "Mark as incomplete" : "Mark as complete", systemImage: subTask.isCompleted ? "checkmark.circle" : "checkmark.circle.fill")
                })
                Button(role: .destructive, action: {
                    subTaskToDelete = subTask
                    showingAlert = true
                }, label: {
                    Label("Delete", systemImage: "trash")
                })
            })
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure you want to delete this?"),
                message: Text("There is no undo"),
                primaryButton: .destructive(Text("Delete")) {
                    if let subTask = subTaskToDelete {
                        taskManager.deleteTask(subTask)
                    }
                },
                secondaryButton: .cancel()
            )
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
                    Text("Notes:", comment: "Headline for the notes section in the task detail view.")
                        .font(.headline)
                    Text(desc)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
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
