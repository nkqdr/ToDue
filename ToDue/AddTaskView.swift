//
//  AddTaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Binding var isPresented: Bool
    @StateObject var taskEditor: TaskEditor
    @State private var saveButtonDisabled = true
    
    private var dateRange: PartialRangeFrom<Date> {
        let task = taskEditor.task
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: task != nil ? min(task!.date!, Date.now) : Date.now)
        return calendar.date(from: startComponents)!...
    }
    
    var body: some View {
        let editMode = taskEditor.task != nil
        return NavigationView {
            Form {
                Group {
                    Section("Information") {
                        TextField("Title", text: $taskEditor.taskTitle)
                            .onChange(of: taskEditor.taskTitle) {
                                if ($0.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                                    saveButtonDisabled = false
                                } else {
                                    saveButtonDisabled = true
                                }
                            }
                        DatePicker("Due date:", selection: $taskEditor.taskDueDate, in: dateRange, displayedComponents: .date)
                    }
                    Section("Additional Notes: (Optional)") {
                        TextEditor(text: $taskEditor.taskDescription)
                            .frame(minHeight: 100)
                            .disableAutocorrection(true)
                            .submitLabel(.done)
                    }
                }
                .listRowBackground(Color("Accent2").opacity(0.3))
            }
            .navigationTitle(editMode ? "Edit task" : "New task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: handleSave)
                        .disabled(editMode ? taskEditor.taskTitle == "" : saveButtonDisabled)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        hideKeyboard()
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                    }
                }
            }
            .background(Color("Background"))
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
