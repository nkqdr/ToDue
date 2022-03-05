//
//  ContentView.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

struct ContentView: View {
    let coreDM: CoreDateManager
    @State private var taskDescription = ""
    @State private var date = Date.now
    @State private var taskArray = [Task]()
    @State private var showAddingPage = false
    @State private var saveButtonDisabled = true
    @State private var remainingTime = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Next due date in")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Text"))
                        Text(remainingTime)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Text"))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    ForEach (taskArray) { task in
                        let index = taskArray.firstIndex(of: task)
                        TaskContainer(task: task, geometry: geometry, showBackground: index == 0)
                            .contextMenu(menuItems: {
                                Button(role: .cancel, action: {
                                    print("Edit")
                                }, label: {
                                    Label("Edit", systemImage: "pencil")
                                })
                                Button(role: .destructive, action: {
                                    coreDM.deleteTask(task: task)
                                    displayTasks()
                                }, label: {
                                    Label("Delete", systemImage: "trash")
                                })
                            })
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color("Background"))
                // The button which opens the adding sheet.
                ZStack {
                    Circle()
                        .fill(Color("Text"))
                        .frame(width: 60, height: 60)
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(Color("Background"))
                }
                .position(x: geometry.size.width - 60, y: geometry.size.height - 60)
                .onTapGesture {
                    showAddingPage = true
                }
                // Top and bottom SafeArea blurs
                Rectangle()
                    .fill(Color("Background"))
                    .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top)
                    .position(x: geometry.size.width / 2, y: -25)
                Rectangle()
                    .fill(Color("Background"))
                    .frame(width: geometry.size.width, height: geometry.safeAreaInsets.bottom)
                    .position(x: geometry.size.width / 2, y: geometry.size.height + 18)
            }
        }
        .onAppear(perform: {
            displayTasks()
        })
        .sheet(isPresented: $showAddingPage, content: {
            let dateRange: PartialRangeFrom<Date> = {
                let calendar = Calendar.current
                let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date.now)
                return calendar.date(from: startComponents)!...
            }()
            VStack(alignment: .leading) {
                Text("Create a new Task!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))
                Spacer()
                Spacer()
                Text("Enter a short description for this task:")
                    .font(.headline)
                    .foregroundColor(Color("Text"))
                    .padding(.horizontal)
                TextField("Description...", text: $taskDescription)
                    .submitLabel(.done)
                    .onChange(of: taskDescription, perform: {
                        if ($0 != "") {
                            saveButtonDisabled = false
                        } else {
                            saveButtonDisabled = true
                        }
                    })
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                Text("Enter a due date for this task:")
                    .font(.headline)
                    .foregroundColor(Color("Text"))
                    .padding(.horizontal)
                DatePicker("", selection: $date, in: dateRange)
                    .labelsHidden()
                    .foregroundColor(Color("Text"))
                    .datePickerStyle(.graphical)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                Spacer()
                Button{
                    showAddingPage = false
                    coreDM.saveTask(taskDescription: taskDescription, date: date)
                    displayTasks()
                    taskDescription = ""
                    date = Date.now
                } label: {
                    Text("Save")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .animation(.default, value: saveButtonDisabled)
                .disabled(saveButtonDisabled)
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(saveButtonDisabled ? Color.gray : Color("Accent1"))
                .foregroundColor(Color("Text"))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(Color("Background"))
        })
    }
    
    func getRemainingDays() {
        if (taskArray.isEmpty) {
            remainingTime = "No Tasks!"
            return
        }
        let diff = Calendar.current.dateComponents([.year, .month, .day], from: Date.now, to: taskArray[0].date!)
        var outputStr = ""
        if (diff.year != nil && diff.year != 0) {
            outputStr += "\(diff.year!) "
            outputStr += diff.year == 1 ? "Year " : "Years "
        }
        if (diff.month != nil && diff.month != 0) {
            outputStr += "\(diff.month!) "
            outputStr += diff.month == 1 ? "Month " : "Months "
        }
        outputStr += "\(diff.day ?? 0) "
        outputStr += diff.day == 1 ? "Day" : "Days"
        remainingTime = outputStr
    }
    
    func displayTasks() {
        var array = coreDM.getAllTasks()
        array.sort {
            $0.date! < $1.date!
        }
        taskArray = array
        getRemainingDays()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(coreDM: CoreDateManager())
    }
}
