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
    @StateObject private var singleTaskManager: SingleTaskManager
    var task: Task
    
    init(task: Task) {
        self.task = task
        self._singleTaskManager = StateObject(wrappedValue: SingleTaskManager(task: task))
    }
    
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
            onDelete: { singleTaskManager.delete(currentSubTask!) },
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
            TaskFormView(isPresented: $showEditTaskSheet, taskEditor: TaskEditor(task: task))
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
        .environmentObject(singleTaskManager)
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
        let subTaskArray = singleTaskManager.subTasks
        let incomplete = subTaskArray.filter { !$0.isCompleted }
        let completed = subTaskArray.filter { $0.isCompleted }
        Section(header: Text(incomplete.isEmpty ? "" : "Sub-Tasks")) {
            ForEach(incomplete) { subTask in
                SubtaskView(subTask: subTask, onEdit: launchEditSubtask)
            }
        }
        Section(header: Text(completed.isEmpty ? "" : "Completed")) {
            ForEach(completed) { subTask in
                SubtaskView(subTask: subTask, onEdit: launchEditSubtask)
            }
        }
        Spacer(minLength: 20)
            .listRowBackground(Color("Background"))
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
