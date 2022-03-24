//
//  ContentView.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coreDM: CoreDataManager
    @Namespace var namespace
    @State private var taskArray = [Task]()
    @State private var showAddingPage = false
    @State private var showCompletedPage = false
    @State private var showSettingsPage = false
    @State private var remainingTime = ""
    @State private var scrollOffset = 0.0
    @State private var titleOpacity = 0.0
    @State private var showTaskDetail = false
    @State private var selectedTask: Task? = nil
    
    var body: some View {
        NavigationView {
                ZStack {
                    if (!showTaskDetail) {
                        mainScrollView
                        addTaskButton
                    } else {
                        TaskDetailView(showDetail: $showTaskDetail, namespace: namespace, task: selectedTask!)
                            .background(Color("Background"))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Next Due Date in")
                                .font(.subheadline)
                                .opacity(titleOpacity)
                                .foregroundColor(.gray)
                            Text(remainingTime)
                                .font(.headline)
                                .fontWeight(.bold)
                                .opacity(titleOpacity)
                        }
                        .frame(maxWidth: .infinity)
                        .offset(x: 25, y: 0)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if !showTaskDetail {
                            Menu {
                                Button(role: .cancel, action: {
                                    showCompletedPage = true
                                }, label: {
                                    Label("Show Completed", systemImage: "rectangle.fill.badge.checkmark")
                                })
                                Button(role: .cancel, action: {
                                    showSettingsPage = true
                                }, label: {
                                    Label("Settings", systemImage: "gear")
                                })
                                Button(role: .cancel, action: {
                                    print("Give Feedback")
                                }, label: {
                                    Label("Give Feedback", systemImage: "star.circle")
                                })
                                // Disabled because it is not implemented yet.
                                .disabled(true)
                            } label: {
                                Label("", systemImage: "ellipsis.circle").imageScale(.large)
                            }
                        } else {
                            Button("Cancel") {
                                withAnimation(.spring()) {
                                    showTaskDetail = false
                                }
                            }
                        }
                    }
                }
                .background(Color("Background"))
                .onAppear(perform: displayTasks)
                .sheet(isPresented: $showCompletedPage, onDismiss: displayTasks, content: {
                    CompletedTasksView(namespace: namespace, isPresented: $showCompletedPage)
                })
                .sheet(isPresented: $showAddingPage, onDismiss: displayTasks, content: {
                    AddTaskView(isPresented: $showAddingPage)
                })
                .sheet(isPresented: $showSettingsPage, onDismiss: displayTasks, content: {
                    SettingsView(isPresented: $showSettingsPage)
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var mainScrollView: some View {
        ScrollView {
            Group {
                Text("Next Due Date in")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(1 + scrollOffset * 0.001, anchor: .leading)
                Text(remainingTime)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(1 + scrollOffset * 0.001, anchor: .leading)

                ForEach (taskArray) { task in
                    let index = taskArray.firstIndex(of: task)
                    TaskContainer(openDetailView: {openTaskDetail(task: task, delay: 0.3)}, namespace: namespace, task: task, showBackground: index == 0, onUpdate: displayTasks)
                        .onTapGesture {
                            openTaskDetail(task: task, delay: 0)
                        }
                }
                .animation(.spring(), value: taskArray)
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: ViewOffsetKey.self, value: proxy.frame(in: .named("scroll")).minY)
                    }
                )
                .onPreferenceChange(ViewOffsetKey.self) { newValue in
                    if (abs(scrollOffset - newValue) > 50 || newValue > 150) {
                        return
                    }
                    scrollOffset = newValue
                    withAnimation(.easeInOut(duration: 0.1)) {
                        if (scrollOffset < 25) {
                            titleOpacity = 1
                        } else {
                            titleOpacity = 0
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .coordinateSpace(name: "scroll")
    }
    
    var addTaskButton: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .fill(Color("Text"))
                    .frame(width: 60, height: 60)
                Image(systemName: "plus")
                    .font(.largeTitle)
                    .foregroundColor(Color("Background"))
            }
            .position(x: geometry.frame(in: .global).maxX - 50, y: geometry.frame(in: .global).maxY - 120)
            .onTapGesture {
                showAddingPage = true
        }
        }
    }
    
    func openTaskDetail(task: Task, delay: Double) {
        selectedTask = task
        withAnimation(.spring().delay(delay)) {
            showTaskDetail.toggle()
        }
    }
    
    func getRemainingDays() {
        if (taskArray.isEmpty) {
            remainingTime = "No Tasks!"
            return
        }
        let diff = Calendar.current.dateComponents([.year, .month, .day], from: Date.now.removeTimeStamp!, to: taskArray[0].date!)
        var outputStr = ""
        if (diff.year != nil && diff.year != 0) {
            outputStr += "\(diff.year!) "
            outputStr += diff.year == 1 ? "Year " : "Years "
        }
        if (diff.month != nil && diff.month != 0) {
            outputStr += "\(diff.month!) "
            outputStr += diff.month == 1 ? "Month " : "Months "
        }
        outputStr += "\(diff.day != nil ? diff.day! : 0) "
        outputStr += diff.day != nil && diff.day! == 1 ? "Day" : "Days"
        if (diff.day != nil && diff.month != nil && diff.year != nil && diff.day! < 0 && diff.month! <= 0 && diff.year! <= 0) {
            remainingTime = "Task is past due!"
        } else {
            remainingTime = outputStr
        }
    }
    
    func displayTasks() {
        var array = coreDM.getAllTasks()
        array = array.filter { task in
            !task.isCompleted
        }
        taskArray = array
        getRemainingDays()
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
