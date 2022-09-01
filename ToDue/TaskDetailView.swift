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
    @FetchRequest var subTasks: FetchedResults<SubTask>
    var task: Task
    
    init(task: Task) {
        self.task = task
        self._subTasks = FetchRequest(
            entity: SubTask.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \SubTask.createdAt, ascending: true)],
            predicate: NSPredicate(format: "task == %@", task),
            animation: .spring()
        )
    }
    
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
            .listRowBackground(Color("Accent2").opacity(0.3))
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
            } message: {
                Text(currentSubTask?.wrappedTitle ?? "")
                    .font(.headline).fontWeight(.bold)
            }
        }
        .background(Color("Background"))
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
        .sheet(isPresented: $showAddSubtaskSheet, onDismiss: {
            currentSubTask = nil
        }) {
            AddSubtaskView(isPresented: $showAddSubtaskSheet, subtaskEditor: SubtaskEditor(currentSubTask, on: task))
            // TODO: Once iOS 16 is out, use .presentationDetents here!
        }
        .sheet(isPresented: $showEditTaskSheet) {
            AddTaskView(isPresented: $showEditTaskSheet, taskEditor: TaskEditor(task: task))
        }
    }
    
    func subTaskView(_ subTask: SubTask) -> some View {
            HStack {
                Text(subTask.title ?? "")
                    .font(.headline)
                    .fontWeight(.bold)
                    .strikethrough(subTask.isCompleted, color: Color("Text"))
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
                    .tint(.mint)
                editSubTaskButton(subTask)
                    .tint(.indigo)
            }
            .contextMenu {
                editSubTaskButton(subTask)
                deleteSubTaskButton(subTask)
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
    
    private func editSubTaskButton(_ subTask: SubTask) -> some View {
        Button {
            currentSubTask = subTask
            showAddSubtaskSheet.toggle()
        } label: {
            Label("Edit", systemImage: "pencil")
        }
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
            currentSubTask = subTask
            showingAlert = true
        }, label: {
            Label("Delete", systemImage: "trash")
        })
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
    
    var dueDate: some View {
        Text("Due: \(Utils.dateFormatter.string(from: task.date ?? Date.now))", comment: "Label in detail view that displays when this task is due.")
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
    
    @ViewBuilder
    var subTaskList: some View {
        let subTaskArray = subTasks.map { $0 }
        if !subTaskArray.isEmpty {
            let incomplete = subTaskArray.filter { !$0.isCompleted }
            if !incomplete.isEmpty {
                Section("Sub-Tasks") {
                    ForEach(incomplete) { subTask in
                        subTaskView(subTask)
                    }
                }
            }
            let completed = subTaskArray.filter { $0.isCompleted }
            if !completed.isEmpty {
                Section("Completed") {
                    ForEach(completed) { subTask in
                        subTaskView(subTask)
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
        static let subTaskBackgroundColor: Color = Color("Accent2").opacity(0.3)
    }
}
