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
    @StateObject var subtaskEditor: SubtaskEditor
    
    var body: some View {
        let editMode = subtaskEditor.subtask != nil
        NavigationView {
            Form {
                Section("Information") {
                    TextField("Title", text: $subtaskEditor.subtaskTitle)
                        .submitLabel(.done)
                        .onChange(of: subtaskEditor.subtaskTitle, perform: subtaskEditor.changeTitleValue)
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
                        .disabled(editMode ? subtaskEditor.subtaskTitle == "" : subtaskEditor.saveButtonDisabled)
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
        taskManager.saveSubtask(subtaskEditor)
        isPresented = false
    }
}

struct AddSubtaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubtaskView(isPresented: .constant(true), subtaskEditor: SubtaskEditor(on: Task()))
            .environmentObject(TaskManager())
    }
}
