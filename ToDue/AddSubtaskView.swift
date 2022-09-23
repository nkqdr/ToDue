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
        let disableSaveButton = editMode ? subtaskEditor.subtaskTitle == "" : subtaskEditor.saveButtonDisabled
        NavigationView {
            Form {
                Section(header: Text("Information")) {
                    VersionAwareTitleTextField
                }
                .listRowBackground(Color("Accent2").opacity(0.3))
            }
            .background(Color("Background").ignoresSafeArea())
            .hideScrollContentBackgroundIfNecessary()
            .versionAwareSheetFormToolbar(isPresented: $isPresented, disableButton: disableSaveButton, onSave: handleSave)
            .navigationTitle(editMode ? "Edit subtask" : "Add subtask")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private var VersionAwareTitleTextField: some View {
        if #available(iOS 15.0, *) {
            TextField("Title", text: $subtaskEditor.subtaskTitle)
                .submitLabel(.done)
                .onChange(of: subtaskEditor.subtaskTitle, perform: subtaskEditor.changeTitleValue)
        } else {
            TextField("Title", text: $subtaskEditor.subtaskTitle)
                .onChange(of: subtaskEditor.subtaskTitle, perform: subtaskEditor.changeTitleValue)
        }
    }
    
    private func handleSave() {
        taskManager.saveSubtask(subtaskEditor)
        isPresented = false
    }
}


extension View {
    func versionAwareSheetFormToolbar(isPresented: Binding<Bool>, disableButton: Bool, onSave: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented.wrappedValue.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: onSave)
                        .disabled(disableButton)
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
        } else {
            return self.toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented.wrappedValue.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: onSave)
                        .disabled(disableButton)
                }
            }
        }
    }
}


struct AddSubtaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubtaskView(isPresented: .constant(true), subtaskEditor: SubtaskEditor(on: Task()))
            .environmentObject(TaskManager())
    }
}
