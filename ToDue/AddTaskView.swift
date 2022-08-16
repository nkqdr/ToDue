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
    @State private var taskDescription = ""
    @State private var date = Date.now
    @State private var saveButtonDisabled = true
    
    var body: some View {
        let dateRange: PartialRangeFrom<Date> = {
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date.now)
            return calendar.date(from: startComponents)!...
        }()
        return ScrollView {
            VStack(alignment: .leading) {
                Text("Create a new Task!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))
                    .padding(.bottom, 50)
                Text("Enter a short description for this task:")
                    .font(.headline)
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
                Text("Enter a due date for this task:")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))
                    .padding(.horizontal)
                DatePicker("", selection: $date, in: dateRange, displayedComponents: .date)
                    .labelsHidden()
                    .foregroundColor(Color("Text"))
                    .datePickerStyle(.graphical)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                Button{
                    isPresented = false
                    date = date.removeTimeStamp!
                    taskManager.addNewTask(description: taskDescription, date: date)
                    taskDescription = ""
                    date = Date.now
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color("Background"))
    }
}

struct RoundedRectangleButtonStyle: ButtonStyle {
    var isDisabled: Bool
      func makeBody(configuration: Configuration) -> some View {
        HStack {
          Spacer()
            configuration.label.foregroundColor(isDisabled ? Color("Text") : Color.white)
          Spacer()
        }
        .padding(.horizontal)
        .background(isDisabled ? Color.gray.cornerRadius(10) : Color.blue.cornerRadius(10))
        .scaleEffect(configuration.isPressed ? 0.95 : 1)
      }
}

struct AddTaskView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskView(isPresented: .constant(true))
    }
}
