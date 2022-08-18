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
    @State private var taskDescription: String
    @State private var date: Date
    @State private var saveButtonDisabled = true
    var task: Task?
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        _taskDescription = State(initialValue: "")
        _date = State(initialValue: Date.now)
    }
    init(isPresented: Binding<Bool>, task: Task) {
        self._isPresented = isPresented
        self.task = task
        _taskDescription = State(initialValue: task.taskDescription ?? "")
        _date = State(initialValue: task.date ?? Date.now)
    }
    
    var body: some View {
        let editMode = task != nil
        let dateRange: PartialRangeFrom<Date> = {
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: editMode ? task!.date! : Date.now)
            return calendar.date(from: startComponents)!...
        }()
        return ScrollView {
            VStack(alignment: .leading) {
                Text(editMode ? "Edit task" : "Create a new Task!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))
                    .padding(.bottom, 50)
                Text("Description:")
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
                Text("Due date:")
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
                    if let newTask = task {
                        taskManager.updateTask(newTask, description: taskDescription, date: date, isCompleted: newTask.isCompleted)
                    } else {
                        taskManager.addNewTask(description: taskDescription, date: date)
                    }
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
