//
//  AddSubtaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 13.08.22.
//

import SwiftUI

struct AddSubtaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var taskDescription: String = ""
    @Binding var isPresented: Bool
    @State private var saveButtonDisabled = true
    var subTask: SubTask?
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        _taskDescription = State(initialValue: "")
    }
    
    init(isPresented: Binding<Bool>, subTask: SubTask) {
        self._isPresented = isPresented
        self.subTask = subTask
        _taskDescription = State(initialValue: subTask.title ?? "")
    }
    
    var body: some View {
        let editMode = subTask != nil
        let task = taskManager.currentTask!
        VStack(alignment: .leading) {
            Spacer()
            Text("Enter a short description:")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("Text"))
                .padding(.horizontal)
            TextField("Description...", text: $taskDescription)
                .submitLabel(.done)
                .textFieldStyle(.roundedBorder)
                .onChange(of: taskDescription, perform: {
                    if ($0.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                        saveButtonDisabled = false
                    } else {
                        saveButtonDisabled = true
                    }
                })
                .padding(.horizontal)
                .padding(.bottom, 40)
            Button{
                isPresented = false
                if let st = subTask {
                    taskManager.editSubTask(st, description: taskDescription)
                } else {
                    taskManager.addSubTask(to: task, description: taskDescription)
                }
            } label: {
                Text("Save")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding()
            }
            .buttonStyle(RoundedRectangleButtonStyle(isDisabled: saveButtonDisabled))
            .disabled(editMode ? taskDescription == "" : saveButtonDisabled)
        }
        .padding()
        .background(Color("Background"))
    }
}

struct AddSubtaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddSubtaskView(isPresented: .constant(true))
    }
}
