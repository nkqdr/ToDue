//
//  TaskDetailView.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.22.
//

import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var taskManager: TaskManager
    @Binding var showDetail: Bool
    // Used for a fade-in effect.
    @State var showContents: Bool = false
    @State var showAddSubtaskSheet: Bool = false
    var namespace: Namespace.ID
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        let task = taskManager.currentTask!
        return ZStack {
            backgroundRectangle
            ScrollView {
                HStack {
                    VStack {
                        Text(dateFormatter.string(from: task.date ?? Date.now))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matchedGeometryEffect(id: "date_\(task.id!)", in: namespace)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(task.taskDescription ?? "")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matchedGeometryEffect(id: "description_\(task.id!)", in: namespace)
                            .font(.title2)
                            .foregroundColor(Color("Text"))
                    }
                    .padding()
                    if showContents {
                        Divider()
                            .padding(.vertical)
                        Button {
                            // TODO: Implement edit functionality
//                            coreDM.removeAllSubTasks(from: task)
                        } label: {
                            Label("", systemImage: "pencil")
                                .scaleEffect(1.3)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 20)
                if showContents {
                    VStack (alignment: .leading) {
                        if !taskManager.currentSubTaskArray.isEmpty {
                            ProgressBar(progress: taskManager.progress(for: task))
                                .padding(.bottom, 20)
                        }
                        HStack (alignment: .bottom) {
                            Text("Sub-Tasks:")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                showAddSubtaskSheet.toggle()
                            } label: {
                                Label("Add", systemImage: "plus")
                            }
                        }
                        subTaskList
                    }
                    .padding()
                }
            }
            .onAppear {
                withAnimation(.easeInOut.delay(0.3)) {
                    showContents = true
                }
            }
            .sheet(isPresented: $showAddSubtaskSheet) {
                AddSubtaskView(isPresented: $showAddSubtaskSheet)
                // Once iOS 16 is out, use .presentationDetents here!
            }
        }
    }
    
    var backgroundRectangle: some View {
        let task = taskManager.currentTask!
        return RoundedRectangle(cornerRadius: 15)
            .fill(.ultraThinMaterial)
            .matchedGeometryEffect(id: "background_\(task.id!)", in: namespace)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
    }
    
    var subTaskList: some View {
        let task = taskManager.currentTask!
        return ForEach (taskManager.currentSubTaskArray) { subTask in
            HStack {
                Text(subTask.title!)
                    .font(.title3)
                    .fontWeight(.bold)
                    .padding(.leading)
                Spacer()
                Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .frame(width: 50, height: 50)
                    .padding(.trailing)
                    .onTapGesture {
                        Haptics.shared.play(.medium)
                        task.objectWillChange.send()
                        taskManager.toggleCompleted(subTask)
                    }
            }
            .background(RoundedRectangle(cornerRadius: 15).fill(Color("Accent1")))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func closeDetailView() {
        withAnimation(.spring()) {
            showDetail.toggle()
        }
    }
}
