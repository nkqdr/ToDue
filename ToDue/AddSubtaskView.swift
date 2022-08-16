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
    
    var body: some View {
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
                taskManager.addSubTask(to: task, description: taskDescription)
                taskDescription = ""
            } label: {
                Text("Save")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding()
            }
            .buttonStyle(RoundedRectangleButtonStyle(isDisabled: saveButtonDisabled))
            .disabled(saveButtonDisabled)
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
