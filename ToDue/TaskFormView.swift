//
//  TaskFormView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct TaskFormView: View {
    @EnvironmentObject var taskManager: TaskManager
    @ObservedObject private var categoryManager = TaskCategoryManager.shared
    @Binding var isPresented: Bool
    @StateObject var taskEditor: TaskEditor
    
    private var dateRange: PartialRangeFrom<Date> {
        let task = taskEditor.task
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: task != nil ? min(task!.date!, Date()) : Date())
        return calendar.date(from: startComponents)!...
    }
    
    var body: some View {
        let editMode = taskEditor.task != nil
        let disableSaveButton = editMode ? taskEditor.taskTitle == "" : taskEditor.saveButtonDisabled
        return NavigationView {
            Form {
                Group {
                    Section {
                        TextField("Title", text: $taskEditor.taskTitle)
                            .onChange(of: taskEditor.taskTitle, perform: taskEditor.changeTitle)
                    }
                    Section(header: Text("Information")) {
                        Picker("Task type", selection: $taskEditor.hasDeadline) {
                            Text("Deadline").tag(true)
                            Text("No Deadline").tag(false)
                        }
                        .pickerStyle(.segmented)
                        if taskEditor.hasDeadline {
                            DatePicker("Due date:", selection: $taskEditor.taskDueDate, in: dateRange, displayedComponents: .date)
                        }
                        VersionAwarePicker
                    }
                    Section(header: Text("task_form_optional_information")) {
                        TextArea("Notes", text: $taskEditor.taskDescription)
                            .frame(minHeight: 100)
                            .disableAutocorrection(true)
                    }
                    Section(header: Text("task_form_scheduling"), footer: Text("task_form_scheduling_footer")) {
                        Toggle("schedule_task_toggle", isOn: $taskEditor.isScheduled)
                        if taskEditor.isScheduled {
                            DatePicker("schedule_task_date", selection: $taskEditor.scheduledDate, in: Date.rangeFromToday, displayedComponents: .date)
                        }
                    }
                }
                .themedListRowBackground()
            }
            .navigationTitle(editMode ? "Edit task" : "New task")
            .navigationBarTitleDisplayMode(.inline)
            .versionAwareSheetFormToolbar(isPresented: $isPresented, disableButton: disableSaveButton, onSave: handleSave)
            .background(Color("Background").ignoresSafeArea())
            .hideScrollContentBackgroundIfNecessary()
        }
    }
    
    @ViewBuilder
    private var VersionAwarePicker: some View {
        if #available(iOS 16.0, *) {
            Picker("Category:", selection: $taskEditor.category) {
                Text("None").tag(TaskCategory?.none)
                ForEach($categoryManager.categories) { $category in
                    Text(category.categoryTitle ?? "").tag(category as TaskCategory?)
                }
            }
        } else {
            HStack {
                Text("Category:")
                Spacer()
                Picker("\(taskEditor.category?.categoryTitle ?? "None")", selection: $taskEditor.category) {
                    Text("None").tag(TaskCategory?.none)
                    ForEach($categoryManager.categories) { $category in
                        Text(category.categoryTitle ?? "").tag(category as TaskCategory?)
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
    
    private func handleSave() {
        taskManager.save(taskEditor)
        isPresented = false
    }
}

struct TaskFormView_Previews: PreviewProvider {
    static var previews: some View {
        TaskFormView(isPresented: .constant(true), taskEditor: TaskEditor())
            .environmentObject(TaskManager.shared)
    }
}
