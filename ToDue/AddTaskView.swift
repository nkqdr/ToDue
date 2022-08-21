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
    @State private var taskTitle: String
    @State private var date: Date
    @State private var saveButtonDisabled = true
    var task: Task?
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        _taskDescription = State(initialValue: "")
        _taskTitle = State(initialValue: "")
        _date = State(initialValue: Date.now)
    }
    init(isPresented: Binding<Bool>, task: Task) {
        self._isPresented = isPresented
        self.task = task
        _taskDescription = State(initialValue: task.taskDescription ?? "")
        _taskTitle = State(initialValue: task.taskTitle ?? "")
        _date = State(initialValue: task.date ?? Date.now)
    }
    
    var body: some View {
        let editMode = task != nil
        let dateRange: PartialRangeFrom<Date> = {
            let calendar = Calendar.current
            let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: editMode ? min(task!.date!, Date.now) : Date.now)
            return calendar.date(from: startComponents)!...
        }()
        return VStack(alignment: .leading) {
            Text(editMode ? "Edit task" : "New task")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color("Text"))
                .padding(.bottom, 20)
            titleAndNotes
            Divider()
            DatePicker("Due date:", selection: $date, in: dateRange, displayedComponents: .date)
                .font(.headline.weight(.bold))
                .foregroundColor(Color("Text"))
                .datePickerStyle(.compact)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 40)
            Button{
                handleSave()
            } label: {
                Text("Save")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding()
            }
            .buttonStyle(RoundedRectangleButtonStyle(isDisabled: editMode ? taskTitle == "" : saveButtonDisabled))
            .disabled(editMode ? taskTitle == "" : saveButtonDisabled)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color("Background"))
    }
    
    var titleAndNotes: some View {
        Group {
            Text("Title:")
                .font(.headline)
                .fontWeight(.bold)
            TextField("Type here...", text: $taskTitle)
                .submitLabel(.done)
                .textFieldStyle(.roundedBorder)
                .onChange(of: taskTitle, perform: {
                    if ($0.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                        saveButtonDisabled = false
                    } else {
                        saveButtonDisabled = true
                    }
                })
            Text("Additional Notes: (Optional)")
                .font(.headline)
                .fontWeight(.bold)
            // TODO: Replace ZStack with commented code when iOS 16 is out
//                    TextField("", text: $taskDescription,  axis: .vertical)
//                        .textFieldStyle(.roundedBorder)
//                        .lineLimit(2...5)
            ZStack {
                TextEditor(text: $taskDescription)
                    .submitLabel(.done)
                Text(taskDescription).opacity(0).padding(.all, 8).lineLimit(5)
            }
        }
        .foregroundColor(Color("Text"))
    }
    
    private func handleSave() {
        isPresented = false
        date = date.removeTimeStamp!
        if let newTask = task {
            taskManager.updateTask(newTask, description: taskDescription, title: taskTitle, date: date, isCompleted: newTask.isCompleted)
        } else {
            taskManager.addNewTask(description: taskDescription, title: taskTitle, date: date)
        }
        taskDescription = ""
        date = Date.now
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
