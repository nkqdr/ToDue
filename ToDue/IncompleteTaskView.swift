//
//  IncompleteTaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

struct IncompleteTaskView: View {
    @EnvironmentObject var taskManager: TaskManager
    @StateObject private var categoryManager = TaskCategoryManager.shared
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Text("Filter by category")
                        Picker("Filter", selection: $taskManager.selectedCategory) {
                            Text("None").tag(TaskCategory?.none)
                            ForEach($categoryManager.categories) { $category in
                                Text(category.categoryTitle ?? "").tag(category as TaskCategory?)
                            }
                        }
                    } label: {
                        Image(systemName: "tray.full")
                    }
                }
                ToolbarItem(placement: .principal) {
                    VStack(alignment: .center) {
                        Text("Next Due Date in")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text(deadlineLabel)
                            .font(.subheadline.weight(.bold))
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
            if let task = taskManager.incompleteTasks.first {
                TaskDetailView(task: task)
            } else {
                Color("Background")
                    .ignoresSafeArea()
            }
        }
        .currentDeviceNavigationViewStyle()
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
        .scaleEffect(max(DrawingConstants.minTitleScaleFactor, min(DrawingConstants.maxTitleScaleFactor, 1 - scrollOffset * DrawingConstants.scrollOffsetScaleFactor)), anchor: .leading)
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
                withAnimation(.easeInOut(duration: DrawingConstants.titleFadeDuration)) {
                    if newValue > DrawingConstants.titleSwitchThreshold {
                        titleOpacity = 1
                    } else {
                        titleOpacity = 0
                    }
                }
            }
        }
    }
    
    private struct DrawingConstants {
        static let minTitleScaleFactor: CGFloat = 0.8
        static let maxTitleScaleFactor: CGFloat = 1.1
        static let scrollOffsetScaleFactor: CGFloat = 0.0005
        static let titleFadeDuration: CGFloat = 0.2
        static let titleSwitchThreshold: CGFloat = 50
    }
}
