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
    @FetchRequest(entity: Task.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Task.date, ascending: true)], predicate: NSPredicate(format: "isCompleted = %d", false), animation: .spring())
    var incompleteTasks: FetchedResults<Task>
    
    var body: some View {
        let deadlineLabel = Utils.remainingTimeLabel(task: incompleteTasks.first)
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
        if incompleteTasks.isEmpty {
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
        let deadlineLabel = Utils.remainingTimeLabel(task: incompleteTasks.first)
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
            ForEach (incompleteTasks) { task in
                let isFirst: Bool = incompleteTasks.first == task
                NavigationLink(destination: {
                    TaskDetailView(task: task)
                }, label: {
                    TaskContainer(task: task, showBackground: isFirst)
                })
            }
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
