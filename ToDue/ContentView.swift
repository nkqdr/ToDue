//
//  ContentView.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var coreDM: CoreDataManager
    @State private var taskArray = [Task]()
    @State private var showAddingPage = false
    @State private var showCompletedPage = false
    @State private var showSettingsPage = false
    @State private var remainingTime = ""
    @State private var scrollOffset = 0.0
    @State private var titleOpacity = 0.0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    Group {
                        Text("Next Due Date in")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .scaleEffect(1 + -scrollOffset * 0.001, anchor: .leading)
                        Text(remainingTime)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .scaleEffect(1 + -scrollOffset * 0.001, anchor: .leading)
                        ForEach (taskArray) { task in
                            let index = taskArray.firstIndex(of: task)
                            TaskContainer(task: task, geometry: geometry, showBackground: index == 0, onUpdate: displayTasks)
                        }
                        .animation(.default, value: taskArray)
                        .background(GeometryReader {
                                        Color.clear.preference(key: ViewOffsetKey.self,
                                                               value: -$0.frame(in: .global).origin.y)
                                    })
                        .onPreferenceChange(ViewOffsetKey.self) {
                            if (abs(scrollOffset - $0) > 100 || $0 < -200) {
                                return
                            }
                            scrollOffset = $0
                            withAnimation(.easeInOut(duration: 0.1)) {
                                if (scrollOffset > -110) {
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
                // The button which opens the adding sheet.
                ZStack {
                    Circle()
                        .fill(Color("Text"))
                        .frame(width: 60, height: 60)
                    Image(systemName: "plus")
                        .font(.largeTitle)
                        .foregroundColor(Color("Background"))
                }
                .position(x: geometry.size.width - 60, y: geometry.size.height - 40)
                .onTapGesture {
                    showAddingPage = true
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
                            
                        }
                    }
            .background(Color("Background"))
            .onAppear(perform: displayTasks)
            .sheet(isPresented: $showCompletedPage, onDismiss: displayTasks, content: {
                CompletedTasksView(isPresented: $showCompletedPage)
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
        outputStr += "\(diff.day != nil ? diff.day! + 1 : 0) "
        outputStr += diff.day != nil && diff.day! + 1 == 1 ? "Day" : "Days"
        remainingTime = outputStr
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
