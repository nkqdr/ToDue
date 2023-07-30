//
//  TaskDetailView.swift
//  ToDue
//
//  Created by Niklas Kuder on 17.08.22.
//

import SwiftUI

struct ReminderListTile: View {
    var reminder: Reminder
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter
    }
    
    var timeFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    var timeBeforeDue: DateComponents? {
        let task = reminder.task
        guard let date = reminder.dateTime, let taskDate = task?.date, taskDate < Date.distantFuture else {
            return nil
        }
        return Calendar.current.dateComponents([.month, .day], from: date, to: taskDate)
    }
    
    var timeBeforeDueString: LocalizedStringKey {
        guard let comps = timeBeforeDue, let days = comps.day, days >= 0, let months = comps.month else {
            return ""
        }
        if months > 0 {
            return "\(months) M, \(days) D"
        } else {
            return "\(days) days_short"
        }
    }
    
    var body: some View {
        if let date = reminder.dateTime {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(timeBeforeDueString) + Text(" ") + Text("before task is due")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                
                HStack {
                    Label(dateFormatter.string(from: date), systemImage: "calendar")
                        .font(.title3.bold())
                    Spacer()
                    Label(timeFormatter.string(from: date), systemImage: "alarm")
                        .foregroundColor(.secondary)
                }
                .font(.title3)
            }
            .padding(.vertical)
            .foregroundColor(date < Date() ? .secondary : nil)
            .frame(maxWidth: .infinity)
            .listRowBackground(Color("Accent2").opacity(0.3))
            .listRowInsets(EdgeInsets())
        }
    }
}

struct ReminderListTile_Previews: PreviewProvider {
    static var reminder: Reminder {
        let reminder = Reminder(context: PersistenceController.shared.persistentContainer.viewContext)
        reminder.dateTime = Date()
        return reminder
    }
    
    static var previews: some View {
        ReminderListTile(reminder: reminder)
    }
}

struct CreateReminderView: View {
    @State private var selectedDateTime: Date = Date()
    @Binding var isPresented: Bool
    var task: Task
    
    var body: some View {
        return NavigationView {
            List {
                DatePicker("Reminder", selection: $selectedDateTime)
                    .datePickerStyle(.graphical)
                    .listRowBackground(Color("Accent2").opacity(0.3))
                    .listRowInsets(EdgeInsets())
            }
            .hideScrollContentBackgroundIfNecessary()
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        ReminderStorage.main.add(to: task, scheduledDate: selectedDateTime)
                        isPresented.toggle()
                    }
                }
            }
        }
    }
}

struct ReminderManagerSheet: View {
    @StateObject private var reminderManager: ReminderManager
    @State private var showConfirmationDialog: Bool = false
    @State private var showCreateReminder: Bool = false
    @State private var reminderToDelete: Reminder? = nil
    @Binding var isPresented: Bool
    var task: Task
    
    init(isPresented: Binding<Bool>, task: Task) {
        self._isPresented = isPresented
        self.task = task
        self._reminderManager = StateObject(wrappedValue: ReminderManager(task: task))
    }
    
    @ViewBuilder
    var reminderScrollView: some View {
        List {
            if !reminderManager.openReminders.isEmpty {
                Section(header: Text("Open")) {
                    ForEach(reminderManager.openReminders) { reminder in
                        ReminderListTile(reminder: reminder)
                            .padding(.horizontal)
                            .versionAwareDeleteSwipeAction {
                                reminderToDelete = reminder
                                showConfirmationDialog = true
                            }
                    }
                }
            }
            if !reminderManager.pastReminders.isEmpty {
                Section(header: Text("Completed")) {
                    ForEach(reminderManager.pastReminders) { reminder in
                        ReminderListTile(reminder: reminder)
                            .padding(.horizontal)
                            .versionAwareDeleteSwipeAction {
                                reminderToDelete = reminder
                                showConfirmationDialog = true
                            }
                    }
                }
            }
        }
        .hideScrollContentBackgroundIfNecessary()
        .background(Color("Background").ignoresSafeArea())
        .versionAwareConfirmationDialog(
            $showConfirmationDialog,
            title: "Are you sure you want to delete this reminder?",
            message: "",
            onDelete: {
                if let reminder = reminderToDelete {
                    ReminderStorage.main.delete(reminder)
                }
            },
            onCancel: { showConfirmationDialog = false }
        )
    }
    
    var body: some View {
        NavigationView {
            Group {
                if reminderManager.reminders.isEmpty {
                    VStack {
                        Spacer()
                        Text("There are no reminders for this task yet")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    reminderScrollView
                }
            }
            .sheet(isPresented: $showCreateReminder) {
                CreateReminderView(isPresented: $showCreateReminder, task: task)
            }
            .navigationTitle("Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("Background").ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateReminder.toggle()
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
    }
}

struct TaskDetailView: View {
    @State var showAddSubtaskSheet: Bool = false
    @State var showEditTaskSheet: Bool = false
    @State var showReminderSheet: Bool = false
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
                        ProgressBar(progress: singleTaskManager.progress)
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
                Menu {
                    Button { showEditTaskSheet = true } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button { showReminderSheet = true } label: {
                        Label("Reminders", systemImage: "alarm")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
        .sheet(isPresented: $showReminderSheet) {
            ReminderManagerSheet(isPresented: $showReminderSheet, task: task)
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
            Group {
                Text("Due: \(Utils.dateFormatter.string(from: task.date ?? Date()))", comment: "Label in detail view that displays when this task is due.") +
                Text(" • (") +
                Text(Utils.shortRemainingTimeLabel(task: task)) +
                Text(")")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline.weight(.semibold))
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
