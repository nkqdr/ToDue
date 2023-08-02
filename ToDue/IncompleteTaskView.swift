//
//  IncompleteTaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

struct IncompleteTaskView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var categoryManager = TaskCategoryManager.shared
    @StateObject private var viewModel = PendingTasksViewModel()
    @State private var showAddingPage = false
    @State private var scrollOffset: CGFloat = 0.0
    @State private var titleOpacity = 0.0
    
    var body: some View {
        let deadlineLabel = Utils.remainingTimeLabel(task: viewModel.displayedTasks.first)
        NavigationView {
            Group {
                if viewModel.displayedTasks.isEmpty {
                    emptyListVStack
                } else {
                    mainScrollView
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Filter", selection: $viewModel.selectedCategory) {
                            Text("None").tag(TaskCategory?.none)
                            ForEach($categoryManager.categories) { $category in
                                Text(category.categoryTitle ?? "").tag(category as TaskCategory?)
                            }
                        }
                    } label: {
                        Image(systemName: viewModel.selectedCategory == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
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
            .background(Color("Background").ignoresSafeArea())
            .sheet(isPresented: $showAddingPage) {
                TaskFormView(isPresented: $showAddingPage, taskEditor: TaskEditor())
            }
            .onChange(of: scenePhase) { newPhase in
                // If the user re-enters the app, refresh the viewmodel because the current date might have changed
                if newPhase == .active {
                    self.viewModel.refresh()
                }
            }
            if let task = viewModel.displayedTasks.first {
                TaskDetailView(task: task)
            } else {
                ZStack {
                    Color("Background")
                        .ignoresSafeArea()
                    Text("Open the sidebar to create a new task!")
                        .font(.headline)
                        .foregroundColor(Color("Text"))
                }
            }
        }
        .currentDeviceNavigationViewStyle()
    }
    
    var emptyListVStack: some View {
        VStack {
            largePageTitle
            TodayTasksView()
            if let category = viewModel.selectedCategory {
                HStack {
                    Text("Filter: \(category.categoryTitle ?? "")")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
            }
            Spacer()
            emptyTaskListButtons
            Spacer()
        }
    }
    
    @ViewBuilder
    var emptyTaskListButtons: some View {
        Button("Create a task") {
            showAddingPage.toggle()
        }
        .versionAwareBorderedButtonStyle()
        if let _ = viewModel.selectedCategory {
            Button("Remove filter") {
                withAnimation(.easeInOut) {
                    viewModel.selectedCategory = nil
                }
            }
            .versionAwareBorderedButtonStyle()
            .padding()
        }
    }
    
    var largePageTitle: some View {
        let deadlineLabel = Utils.remainingTimeLabel(task: viewModel.displayedTasks.first)
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
    
    @ViewBuilder
    var mainScrollView: some View {
        ObservableScrollView(scrollOffset: $scrollOffset, showsIndicators: false) { proxy in
            largePageTitle
            TodayTasksView()
            if let category = viewModel.selectedCategory {
                HStack {
                    Text("Filter: \(category.categoryTitle ?? "")")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding()
            }
            ForEach (viewModel.displayedTasks) { task in
                let isFirst: Bool = viewModel.displayedTasks.first == task
                NavigationLink(destination: {
                    TaskDetailView(task: task)
                }, label: {
                    TaskContainer(task: task, showBackground: isFirst)
                })
            }
            .animation(.spring(), value: viewModel.displayedTasks)
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
