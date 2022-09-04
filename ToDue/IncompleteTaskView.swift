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
    @State private var scrollOffset: CGFloat = 0.0
    @State private var titleOpacity = 0.0
    
    var body: some View {
        let deadlineLabel = Utils.remainingTimeLabel(task: taskManager.incompleteTasks.first)
        NavigationView {
            Group {
                mainScrollView
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(alignment: .center) {
                        Text("Next Due Date in")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(deadlineLabel)
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
                AddTaskView(isPresented: $showAddingPage, taskEditor: TaskEditor())
            }
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    var maybeAddTaskButton: some View {
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
    }
    
    var largePageTitle: some View {
        let deadlineLabel = Utils.remainingTimeLabel(task: taskManager.incompleteTasks.first)
        return Group {
            Text("Next Due Date in")
                .font(.title2)
                .foregroundColor(.gray)
                .fontWeight(.bold)
            Text(deadlineLabel)
                .font(.title.weight(.bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .scaleEffect(max(0.8, min(1.2, 1 - scrollOffset * 0.001)), anchor: .leading)
        .padding(.horizontal)
        .opacity(1 - titleOpacity)
    }
    
    var mainScrollView: some View {
        ObservableScrollView(scrollOffset: $scrollOffset, showsIndicators: false) { proxy in
            largePageTitle
            maybeAddTaskButton
            ForEach (taskManager.incompleteTasks) { task in
                let isFirst: Bool = taskManager.incompleteTasks.first == task
                NavigationLink(destination: {
                    TaskDetailView(task: task)
                }, label: {
                    TaskContainer(task: task, showBackground: isFirst)
                })
            }
            .animation(.spring(), value: taskManager.incompleteTasks)
            .padding(.horizontal)
            .onChange(of: scrollOffset) { newValue in
                withAnimation(.easeInOut(duration: 0.2)) {
                    if newValue > 50 {
                        titleOpacity = 1
                    } else {
                        titleOpacity = 0
                    }
                }
            }
        }
    }
}
