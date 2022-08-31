//
//  AddSubtaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 13.08.22.
//

import SwiftUI

struct AddSubtaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Binding var isPresented: Bool
    @State private var saveButtonDisabled = true
    @StateObject var subtaskEditor: SubtaskEditor
    
    var body: some View {
        let editMode = subtaskEditor.subtask != nil
        NavigationView {
            Form {
                Section("Information") {
                    TextField("Title", text: $subtaskEditor.subtaskTitle)
                        .submitLabel(.done)
                        .onChange(of: subtaskEditor.subtaskTitle) {
                            if ($0.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                                saveButtonDisabled = false
                            } else {
                                saveButtonDisabled = true
                            }
                        }
                }
                .listRowBackground(Color("Accent2").opacity(0.3))
            }
            .background(Color("Background"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: handleSave)
                        .disabled(editMode ? subtaskEditor.subtaskTitle == "" : saveButtonDisabled)
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
            .navigationTitle(editMode ? "Edit subtask" : "Add subtask")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func handleSave() {
        if let st = subtaskEditor.subtask {
            taskManager.editSubTask(st, description: subtaskEditor.subtaskTitle)
        } else {
            if let task = taskManager.currentTask {
                taskManager.addSubTask(to: task, description: subtaskEditor.subtaskTitle)
            }
        }
        isPresented = false
    }
}

struct AddSubtaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubtaskView(isPresented: .constant(true), subtaskEditor: SubtaskEditor())
            .environmentObject(TaskManager())
    }
}
