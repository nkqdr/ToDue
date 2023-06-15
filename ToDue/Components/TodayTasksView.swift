//
//  TodayTasksView.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.02.23.
//

import SwiftUI

struct TodayTasksView: View {
    @ObservedObject private var dailyManager = TodayTasksViewModel()
    @EnvironmentObject var taskManager: TaskManager
    
    private var showTodaysTasks: Bool {
        !(dailyManager.subTasks.isEmpty && dailyManager.tasks.isEmpty)
    }
    
    var taskTitle: LocalizedStringKey {
        LocalizedStringKey(dailyManager.taskTitle)
    }
    
    @ViewBuilder
    var listContainer: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: DrawingConstants.containerCornerRadius)
                .fill(dailyManager.progress < 1 ? DrawingConstants.defaultTaskBackgroundColor : .green.opacity(0.5))
            HStack {
                VStack(alignment: .leading) {
                    Text(Utils.dateFormatter.string(from: dailyManager.taskDueDate))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(taskTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                        .foregroundColor(Color("Text"))
                }
                .multilineTextAlignment(.leading)
                .padding()
                Spacer()
                ProgressCircle(isCompleted: dailyManager.progress == 1, progress: dailyManager.progress)
                    .padding(.trailing)
            }
        }
        .frame(maxHeight: 70)
        .padding(.horizontal)
        .padding(.bottom, 20)
        .animation(.spring(), value: showTodaysTasks)
    }
    
    var body: some View {
        if showTodaysTasks {
            NavigationLink(destination: {
                TodaysTasksDetailView(dailyManager: dailyManager)
            }, label: {
                listContainer
            })
        } else {
            EmptyView()
        }
    }
    
    private struct DrawingConstants {
        static let topTaskBackgroundColor: Color = Color("Accent1")
        static let defaultTaskBackgroundColor: Color = Color("Accent2").opacity(0.3)
        static let completeTaskBackgroundColor: Color = Color("CompleteTask")
        static let topTaskMinHeight: CGFloat = 140
        static let containerCornerRadius: CGFloat = 12
    }
}

fileprivate struct TodaysTasksDetailView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var currentSubTask: SubTask?
    @State var showAddSubtaskSheet: Bool = false
    @State private var showingAlert: Bool = false
    var dailyManager: TodayTasksViewModel
    
    init(dailyManager: TodayTasksViewModel) {
        self.dailyManager = dailyManager
    }
    
    var taskTitle: LocalizedStringKey {
        LocalizedStringKey(dailyManager.taskTitle)
    }
    
    var dueDate: some View {
        Text("Due: \(Utils.dateFormatter.string(from: dailyManager.taskDueDate))", comment: "Label in detail view that displays when this task is due.")
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .foregroundColor(.secondary)
    }
    
    var body: some View {
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
                    taskManager.delete(currentSubTask!)
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
                AddSubtaskView(isPresented: $showAddSubtaskSheet, subtaskEditor: SubtaskEditor(currentSubTask, scheduled: Date()))
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
    
    @ViewBuilder
    func subTaskList(_ subTasks: [SubTask]) -> some View {
        ForEach(subTasks) { subTask in
            SubtaskContainer(title: subTask.title ?? "", isCompleted: subTask.isCompleted, topSubTitle: subTask.task?.taskTitle) {
                Haptics.shared.play(.medium)
                withAnimation {
                    taskManager.toggleCompleted(subTask)
                }
            }
            .contextMenu {
                if subTask.task != nil {
                    Button {
                        withAnimation {
                            taskManager.unscheduleForToday(subTask)
                        }
                    } label: {
                        Label("Remove from today", systemImage: "minus.circle")
                    }
                } else {
                    VersionAwareDestructiveButton {
                        currentSubTask = subTask
                        showingAlert.toggle()
                    }
                }
            }
            .versionAwareSubtaskCompleteSwipeAction(subTask) {
                withAnimation {
                    taskManager.toggleCompleted(subTask)
                }
            }
            .versionAwareAddToDailySwipeAction(isInDaily: true, leading: false, deleteCompletely: subTask.task == nil) {
                if subTask.task == nil {
                    currentSubTask = subTask
                    showingAlert.toggle()
                } else {
                    withAnimation {
                        taskManager.unscheduleForToday(subTask)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func taskList(_ tasks: [Task]) -> some View {
        ForEach(tasks) { task in
            NavigationLink(destination: {
                TaskDetailView(task: task)
            }, label: {
                SubtaskContainer(title: task.taskTitle ?? "", isCompleted: task.isCompleted, progress: SingleTaskManager(task: task).progress) {
                    Haptics.shared.play(.medium)
                    withAnimation {
                        taskManager.toggleCompleted(task)
                    }
                }
                .contextMenu {
                    Button {
                        withAnimation {
                            taskManager.unscheduleForToday(task)
                        }
                    } label: {
                        Label("Remove from today", systemImage: "minus.circle")
                    }
                }
                .versionAwareTaskCompleteSwipeAction(task) {
                    withAnimation {
                        taskManager.toggleCompleted(task)
                    }
                }
                .versionAwareAddToDailySwipeAction(isInDaily: true, leading: false) {
                    withAnimation {
                        taskManager.unscheduleForToday(task)
                    }
                }
            })
        }
    }
    
    @ViewBuilder
    var subTaskList: some View {
        let subTaskArray = dailyManager.subTasks
        let taskArray = dailyManager.tasks
        
        let incompleteSubTasks = subTaskArray.filter { !$0.isCompleted }
        let incompleteTasks = taskArray.filter({ !$0.isCompleted })
        let completedSubTasks = subTaskArray.filter { $0.isCompleted }
        let completedTasks = taskArray.filter({ $0.isCompleted })
        
        Section(header: Text(!incompleteSubTasks.isEmpty || !incompleteTasks.isEmpty ? "Open" : "")) {
            subTaskList(incompleteSubTasks)
            taskList(incompleteTasks)
        }
        Section(header: Text(!completedSubTasks.isEmpty || !completedTasks.isEmpty ? "Completed" : "")) {
            subTaskList(completedSubTasks)
            taskList(completedTasks)
        }
    }
    
    private struct DrawingConstants {
        static let progressBarPadding: CGFloat = 20
    }
}
