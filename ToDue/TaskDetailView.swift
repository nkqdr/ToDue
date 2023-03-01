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
    
    var floatingAddSubtaskButton: some View {
        FloatingActionButton(content: "Add subtask", systemImage: "plus") {
            showAddSubtaskSheet.toggle()
        }
    }
    
    var mainListView: some View {
        List {
            Group {
                VStack(alignment: .leading) {
                    dueDate
                    if let category = task.category {
                        Text(category.categoryTitle ?? "")
                            .font(.callout)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .foregroundColor(.secondary)
                            .versionAwareRegularMaterialBackground()
                            .padding(.bottom, DrawingConstants.dueDatePadding)
                    }
                    taskDesc
                    if !task.subTaskArray.isEmpty {
                        ProgressBar(progress: taskManager.progress(for: task))
                            .padding(.bottom, DrawingConstants.progressBarPadding)
                    }
                }
                .listRowBackground(Color("Background"))
                .listRowInsets(EdgeInsets())
                subTaskList
            }
            .themedListRowBackground()
        }
        .groupListStyleIfNecessary()
        .background(Color("Background").ignoresSafeArea())
        .hideScrollContentBackgroundIfNecessary()
        .versionAwareConfirmationDialog(
            $showingAlert,
            title: "Are you sure you want to delete this?",
            message: currentSubTask?.wrappedTitle ?? "",
            onDelete: { taskManager.deleteTask(currentSubTask!) },
            onCancel: {
            showingAlert = false
            currentSubTask = nil
        })
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
        .versionAwareNavigationTitleDisplayMode()
        .sheet(isPresented: $showAddSubtaskSheet, onDismiss: {
            currentSubTask = nil
        }) {
            AddSubtaskView(isPresented: $showAddSubtaskSheet, subtaskEditor: SubtaskEditor(currentSubTask, on: task))
                .versionAwarePresentationDetents()
        }
        .sheet(isPresented: $showEditTaskSheet) {
            AddTaskView(isPresented: $showEditTaskSheet, taskEditor: TaskEditor(task: task))
        }
    }
    
    var body: some View {
        ZStack {
            mainListView
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    floatingAddSubtaskButton
                }
            }
        }
    }
    
    var addSubTaskButton: some View {
        HStack {
            Spacer()
            Button("Add subtask") {
                showAddSubtaskSheet.toggle()
            }
            .buttonStyle(.borderless)
            Spacer()
        }
    }
    
    @ViewBuilder
    var dueDate: some View {
        if let date = task.date, date < Date.distantFuture {
            Text("Due: \(Utils.dateFormatter.string(from: task.date ?? Date()))", comment: "Label in detail view that displays when this task is due.")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.headline)
                .foregroundColor(.secondary)
                
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
                    if #available(iOS 15.0, *) {
                        Text(desc)
                            .textSelection(.enabled)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        Text(desc)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    func launchEditSubtask(subTask: SubTask) {
        currentSubTask = subTask
        showAddSubtaskSheet.toggle()
    }
    
    @ViewBuilder
    var subTaskList: some View {
        let subTaskArray = task.subTaskArray
        if !subTaskArray.isEmpty {
            let incomplete = subTaskArray.filter { !$0.isCompleted }
            if !incomplete.isEmpty {
                Section(header: Text("Sub-Tasks")) {
                    ForEach(incomplete) { subTask in
                        SubtaskView(subTask: subTask, onEdit: launchEditSubtask)
                    }
                }
            }
            let completed = subTaskArray.filter { $0.isCompleted }
            if !completed.isEmpty {
                Section(header: Text("Completed")) {
                    ForEach(completed) { subTask in
                        SubtaskView(subTask: subTask, onEdit: launchEditSubtask)
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
