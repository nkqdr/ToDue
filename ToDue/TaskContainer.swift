//
//  TaskContainer.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct TaskContainer: View {
    @EnvironmentObject var taskManager: TaskManager
    @State private var showingAlert: Bool = false
    var openDetailView: () -> Void = {}
    var namespace: Namespace.ID
    var task: Task
    var showBackground: Bool = false
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return ZStack {
            if let id = task.id {
                if taskManager.progress(for: task) == 1 {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.green.opacity(0.5))
                        .matchedGeometryEffect(id: "background_\(id)", in: namespace)
                } else if showBackground && !task.isCompleted {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color("Accent1"))
                        .matchedGeometryEffect(id: "background_\(id)", in: namespace)
                } else {
                    RoundedRectangle(cornerRadius: 15)
                    .fill(
                        Color("Accent2")
                            .opacity(0.3)
                    )
                    .matchedGeometryEffect(id: "background_\(id)", in: namespace)
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(dateFormatter.string(from: task.date ?? Date.now))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matchedGeometryEffect(id: "date_\(id)", in: namespace)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(task.taskDescription ?? "")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matchedGeometryEffect(id: "description_\(id)", in: namespace)
                            .font(showBackground && !task.isCompleted ? .title2 : .title3)
                            .foregroundColor(Color("Text"))
                        Spacer()
                        if taskManager.progress(for: task) == 1 && !task.isCompleted {
                            Text("Complete this task by tapping the circle!")
                                .font(.footnote)
                        }
                    }
                    .padding()
                    Spacer()
                    progressCircle
                }
            }
        }
        .frame(minHeight: showBackground && !task.isCompleted ? 150 : 0)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure you want to delete this?"),
                message: Text("There is no undo"),
                primaryButton: .destructive(Text("Delete")) {
                    taskManager.deleteTask(task)
                },
                secondaryButton: .cancel()
            )
        }
        .contextMenu(menuItems: {
            Button(role: .cancel, action: {
                taskManager.toggleCompleted(task)
            }, label: {
                Label("Mark as \(task.isCompleted ? "uncompleted" : "completed")", systemImage: task.isCompleted ? "checkmark.circle" : "checkmark.circle.fill")
            })
            if !task.isCompleted {
                Button(role: .cancel, action: {
                    taskManager.currentTask = task
                    openDetailView()
                }, label: {
                    Label("Edit", systemImage: "pencil")
                })
            }
            Button(role: .destructive, action: {
                showingAlert = true
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        })
        .padding(.bottom)
    }
    
    @ViewBuilder
    var progressCircle: some View {
        if task.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .frame(width: 30, height: 30)
                .padding(.trailing)
                .onTapGesture {
                    Haptics.shared.play(.medium)
                    taskManager.toggleCompleted(task)
                }
        } else {
            ZStack {
                Circle()
                    .foregroundColor(showBackground && !task.isCompleted ? Color("Accent1") : Color("Accent2").opacity(0.3))
                Circle()
                    .strokeBorder(lineWidth: 2)
                ProgressPie(progress: taskManager.progress(for: task))
            }
            .frame(width: 30, height: 30)
            .padding(.trailing)
            .onTapGesture {
                Haptics.shared.play(.medium)
                taskManager.toggleCompleted(task)
            }
        }
    }
}
