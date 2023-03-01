//
//  DailyTaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.02.23.
//

import SwiftUI

struct DailyTaskView: View {
    @ObservedObject private var dailyManager = DailyTaskManager()
    @EnvironmentObject var taskManager: TaskManager
    @State private var currentSubTask: SubTask?
    @State var showAddSubtaskSheet: Bool = false
    @State private var showingAlert: Bool = false
    
    private var taskDueDate: Date = Date()
    private var taskTitle: LocalizedStringKey = "Today"
    
    private var showDailyTask: Bool {
        !(dailyManager.subTasks.isEmpty && dailyManager.tasks.isEmpty)
    }
    
    var listContainer: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DrawingConstants.containerCornerRadius)
                .fill(dailyManager.progress < 1 ? DrawingConstants.defaultTaskBackgroundColor : .green.opacity(0.5))
            HStack {
                VStack(alignment: .leading) {
                    Text(Utils.dateFormatter.string(from: taskDueDate))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(taskTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                        .foregroundColor(Color("Text"))
                    Spacer()
                }
                .multilineTextAlignment(.leading)
                .padding()
                Spacer()
                ProgressCircle(isCompleted: dailyManager.progress == 1, progress: dailyManager.progress) {
                    
                }
                .padding(.trailing)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
        .animation(.spring(), value: showDailyTask)
    }
    
    var detailView: some View {
        ZStack {
            List {
                Group {
                    VStack(alignment: .leading) {
                        dueDate
                        ProgressBar(progress: dailyManager.progress)
                            .padding(.bottom, DrawingConstants.progressBarPadding)
                    }
                    .listRowBackground(Color("Background"))
                    .listRowInsets(EdgeInsets())
                    subTaskList
                    Spacer()
                        .listRowBackground(Color.clear)
                }
                .themedListRowBackground()
            }
            .groupListStyleIfNecessary()
            .background(Color("Background").ignoresSafeArea())
            .hideScrollContentBackgroundIfNecessary()
            .navigationTitle(taskTitle)
            .navigationBarTitleDisplayMode(.large)
            .versionAwareConfirmationDialog(
                $showingAlert,
                title: "Are you sure you want to delete this?",
                message: currentSubTask?.wrappedTitle ?? "",
                onDelete: {
                    taskManager.deleteTask(currentSubTask!)
                    currentSubTask = nil
                },
                onCancel: {
                    showingAlert = false
                    currentSubTask = nil
                }
            )
            .sheet(isPresented: $showAddSubtaskSheet, onDismiss: {
                currentSubTask = nil
            }) {
                AddSubtaskView(isPresented: $showAddSubtaskSheet, subtaskEditor: SubtaskEditor(currentSubTask))
                    .versionAwarePresentationDetents()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(content: "Add subtask", systemImage: "plus") {
                        showAddSubtaskSheet.toggle()
                    }
                }
            }
        }
    }
    
    var body: some View {
        if showDailyTask {
            NavigationLink(destination: {
                detailView
            }, label: {
                listContainer
            })
        } else {
            EmptyView()
        }
    }
    
    var dueDate: some View {
        Text("Due: \(Utils.dateFormatter.string(from: taskDueDate))", comment: "Label in detail view that displays when this task is due.")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .foregroundColor(.secondary)
    }
    
    func subTaskList(_ subTasks: [SubTask]) -> some View {
        ForEach(subTasks) { subTask in
            SubtaskContainer(title: subTask.title ?? "", isCompleted: subTask.isCompleted, topSubTitle: subTask.task?.taskTitle) {
                Haptics.shared.play(.medium)
                dailyManager.toggleCompleted(subTask)
            }
            .contextMenu {
                if subTask.task != nil {
                    Button {
                        taskManager.removeFromDaily(subTask)
                    } label: {
                        Label("Remove from today", systemImage: "minus.circle")
                    }
                } else {
                    Button {
                        currentSubTask = subTask
                        showingAlert.toggle()
                    } label: {
                        Label("Delete this task", systemImage: "trash")
                    }
                }
            }
            .versionAwareSubtaskCompleteSwipeAction(subTask) {
                taskManager.toggleCompleted(subTask)
            }
            .versionAwareAddToDailySwipeAction(isInDaily: true, leading: false, deleteCompletely: subTask.task == nil) {
                if subTask.task == nil {
                    currentSubTask = subTask
                    showingAlert.toggle()
                } else {
                    taskManager.removeFromDaily(subTask)
                }
            }
        }
    }
    
    func taskList(_ tasks: [Task]) -> some View {
        ForEach(tasks) { task in
            NavigationLink(destination: {
                TaskDetailView(task: task)
            }, label: {
                SubtaskContainer(title: task.taskTitle ?? "", isCompleted: task.isCompleted, progress: taskManager.progress(for: task)) {
                    Haptics.shared.play(.medium)
                    dailyManager.toggleCompleted(task)
                }
                .contextMenu {
                    Button {
                        taskManager.removeFromDaily(task)
                    } label: {
                        Label("Remove from today", systemImage: "minus.circle")
                    }
                }
                .versionAwareTaskCompleteSwipeAction(task) {
                    taskManager.toggleCompleted(task)
                }
                .versionAwareAddToDailySwipeAction(isInDaily: true, leading: false) {
                    taskManager.removeFromDaily(task)
                }
            })
        }
    }
    
    @ViewBuilder
    var subTaskList: some View {
        let subTaskArray = dailyManager.subTasks
        let taskArray = dailyManager.tasks
        if !subTaskArray.isEmpty || !taskArray.isEmpty {
            let incompleteSubTasks = subTaskArray.filter { !$0.isCompleted }
            let incompleteTasks = taskArray.filter({ !$0.isCompleted })
            if !incompleteSubTasks.isEmpty || !incompleteTasks.isEmpty {
                Section(header: Text("Open")) {
                    subTaskList(incompleteSubTasks)
                    taskList(incompleteTasks)
                }
            }
            let completedSubTasks = subTaskArray.filter { $0.isCompleted }
            let completedTasks = taskArray.filter({ $0.isCompleted })
            if !completedSubTasks.isEmpty || !completedTasks.isEmpty {
                Section(header: Text("Completed")) {
                    subTaskList(completedSubTasks)
                    taskList(completedTasks)
                }
            }
        } else {
            // Empty section here for some extra padding
            Section {}
        }
    }
    
    private struct DrawingConstants {
        static let topTaskBackgroundColor: Color = Color("Accent1")
        static let defaultTaskBackgroundColor: Color = Color("Accent2").opacity(0.3)
        static let completeTaskBackgroundColor: Color = Color("CompleteTask")
        static let topTaskMinHeight: CGFloat = 140
        static let containerCornerRadius: CGFloat = 12
        static let progressBarPadding: CGFloat = 20
    }
}

struct DailyTaskView_Previews: PreviewProvider {
    static var previews: some View {
        DailyTaskView()
    }
}
