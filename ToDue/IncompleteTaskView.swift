//
//  IncompleteTaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

struct IncompleteTaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    var taskNamespace: Namespace.ID
    @State private var showAddingPage = false
    @State private var scrollOffset = 0.0
    @State private var titleOpacity = 0.0
    @State private var showTaskDetail = false
    
    var body: some View {
        NavigationView {
                ZStack {
                    if (!showTaskDetail) {
                        mainScrollView
                    } else {
                        TaskDetailView(showDetail: $showTaskDetail, namespace: taskNamespace)
                            .background(Color("Background"))
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(alignment: .center) {
                            Text("Next Due Date in")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(taskManager.remainingTime)
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .opacity(titleOpacity)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if !showTaskDetail {
                            Button {
                                showAddingPage = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        } else {
                            Button{
                                toggleTaskDetail(task: taskManager.currentTask!, delay: 0)
                            } label: {
                                Text("Close")
                            }
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
                Group {
                    Text("Next Due Date in")
                        .font(.title)
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                    Text(taskManager.remainingTime)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .scaleEffect(1 + scrollOffset * 0.001, anchor: .leading)

                ForEach (taskManager.incompleteTasks) { task in
                    let isFirst: Bool = taskManager.incompleteTasks.first == task
                    TaskContainer(openDetailView: {toggleTaskDetail(task: task, delay: 0.3)}, namespace: taskNamespace, task: task, showBackground: isFirst)
                        .onTapGesture {
                            taskManager.currentTask = task
                            toggleTaskDetail(task: task, delay: 0)
                        }
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
    
    func toggleTaskDetail(task: Task, delay: Double) {
        if !showTaskDetail {
            taskManager.currentTask = task
        }
        withAnimation(.spring().delay(delay)) {
            showTaskDetail.toggle()
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
