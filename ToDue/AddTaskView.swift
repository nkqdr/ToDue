//
//  AddTaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct AddTaskView: View {
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
                        Picker("Category:", selection: $taskEditor.category) {
                            Text("None").tag(TaskCategory?.none)
                            ForEach($categoryManager.categories) { $category in
                                Text(category.categoryTitle ?? "").tag(category as TaskCategory?)
                            }
                        }
                        .versionAwarePickerStyle(displayTitle: "Category:")
                    }
                    Section(header: Text("Additional Notes: (Optional)")) {
///                       Possibly replace this in the future?
//                        TextField("Test", text: $taskEditor.taskDescription,  axis: .vertical)
//                            .lineLimit(5...10)
//                            .disableAutocorrection(true)
                        TextEditor(text: $taskEditor.taskDescription)
                            .frame(minHeight: 100)
                            .disableAutocorrection(true)
                    }
                }
                .themedListRowBackground()
            }
            .navigationTitle(editMode ? "Edit task" : "New task")
            .navigationBarTitleDisplayMode(.inline)
            .versionAwareSheetFormToolbar(isPresented: $isPresented, disableButton: disableSaveButton, onSave: handleSave)
            .background(Color("Background"))
            .hideScrollContentBackgroundIfNecessary()
        }
    }
    
    private func handleSave() {
        taskManager.saveTask(taskEditor)
        isPresented = false
    }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(isPresented: .constant(true), taskEditor: TaskEditor())
            .environmentObject(TaskManager())
    }
}
