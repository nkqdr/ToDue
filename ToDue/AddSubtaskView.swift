//
//  AddSubtaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 13.08.22.
//

import SwiftUI

struct AddSubtaskView: View {
    @EnvironmentObject var coreDM: CoreDataManager
    @State private var taskDescription: String = ""
    @Binding var isPresented: Bool
    var task: Task
    @State private var saveButtonDisabled = true
    
    var body: some View {

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
                        coreDM.addSubTask(to: task, subTaskTitle: taskDescription)
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
        AddSubtaskView(isPresented: .constant(true), task: Task())
    }
}
