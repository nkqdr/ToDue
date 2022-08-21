//
//  IncompleteTaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

struct IncompleteTaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showAddingPage = false
    @State private var scrollOffset = 0.0
    @State private var titleOpacity = 0.0
    
    var body: some View {
        NavigationView {
                ZStack {
                    mainScrollView
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(alignment: .center) {
                            Text("Next Due Date in")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            remainingTimeLabel
                                .font(.headline.weight(.bold))
                        }
                        .opacity(titleOpacity)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showAddingPage = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .background(Color("Background"))
                .sheet(isPresented: $showAddingPage) {
                    AddTaskView(isPresented: $showAddingPage)
                }
            }
        .navigationViewStyle(.stack)
    }
    
    var mainScrollView: some View {
        ScrollView(showsIndicators: false) {
            Group {
                if taskManager.remainingTime.month != nil &&
                   taskManager.remainingTime.day != nil {
                    Text("Next Due Date in")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                }
                remainingTimeLabel
                    .font(.title.weight(.bold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .scaleEffect(1 + scrollOffset * 0.001, anchor: .leading)
            .padding(.horizontal)
            
            if taskManager.incompleteTasks.isEmpty {
                GeometryReader { proxy in
                    VStack(alignment: .center) {
                        Spacer(minLength: UIScreen.main.bounds.size.height / 3)
                        Button("Create a task") {
                            showAddingPage.toggle()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            ForEach (taskManager.incompleteTasks) { task in
                let isFirst: Bool = taskManager.incompleteTasks.first == task
                NavigationLink(destination: {
                    TaskDetailView(task: task)
                }, label: {
                    TaskContainer(task: task, showBackground: isFirst)
                })
                .simultaneousGesture(TapGesture().onEnded {
                    taskManager.currentTask = task
                })
            }
            .animation(.spring(), value: taskManager.incompleteTasks)
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
            .padding(.horizontal)
        }
        .coordinateSpace(name: "scroll")
    }
    
    @ViewBuilder
    var remainingTimeLabel: some View {
        if let months = taskManager.remainingTime.month,
            let days = taskManager.remainingTime.day {
            if months > 0 {
                Text("\(months) Months, \(days) Days")
            } else if days >= 0 {
                Text("\(days) Days")
            } else {
                Text("Task is past due!")
            }
        } else {
            Text("No tasks!")
        }
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
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
