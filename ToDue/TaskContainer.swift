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
    var task: Task
    var showBackground: Bool = false
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return ZStack {
            containerBackground
            HStack {
                VStack(alignment: .leading) {
                    Text(dateFormatter.string(from: task.date ?? Date.now))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(task.taskTitle ?? "")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(showBackground && !task.isCompleted ? .title2 : .title3)
                        .foregroundColor(Color("Text"))
                    if let desc = task.taskDescription {
                        Text(desc)
                            .foregroundColor(.secondary)
                            .font(.headline)
                            .lineLimit(1)
                    }
                    Spacer()
                    if taskManager.progress(for: task) == 1 && !task.isCompleted {
                        Text("Complete this task by tapping the circle!")
                            .font(.footnote)
                            .foregroundColor(Color("Text"))
                    }
                }
                .multilineTextAlignment(.leading)
                .padding()
                Spacer()
                progressCircle
            }
        }
        .frame(minHeight: showBackground && !task.isCompleted ? DrawingConstants.topTaskMinHeight : 0)
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
            Button(role: .destructive, action: {
                showingAlert = true
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        })
        .padding(.bottom)
    }
    
    @ViewBuilder
    var containerBackground: some View {
        if taskManager.progress(for: task) == 1 {
            RoundedRectangle(cornerRadius: DrawingConstants.containerCornerRadius)
                .fill(DrawingConstants.completeTaskBackgroundColor)
        } else if showBackground && !task.isCompleted {
            RoundedRectangle(cornerRadius: DrawingConstants.containerCornerRadius)
                .fill(DrawingConstants.topTaskBackgroundColor)
        } else {
            RoundedRectangle(cornerRadius: DrawingConstants.containerCornerRadius)
            .fill(
                DrawingConstants.defaultTaskBackgroundColor
            )
        }
    }
    
    @ViewBuilder
    var progressCircle: some View {
        if task.isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .font(.largeTitle)
                .frame(width: DrawingConstants.progressCircleSize, height: DrawingConstants.progressCircleSize)
                .foregroundColor(Color("Text"))
                .padding(.trailing)
                .onTapGesture {
                    Haptics.shared.play(.medium)
                    taskManager.toggleCompleted(task)
                }
        } else {
            ZStack {
                Circle()
                    .foregroundColor(showBackground && !task.isCompleted ? DrawingConstants.topTaskBackgroundColor : DrawingConstants.defaultTaskBackgroundColor)
                Circle()
                    .strokeBorder(lineWidth: DrawingConstants.progressCircleStrokeWidth)
                ProgressPie(progress: taskManager.progress(for: task))
            }
            .foregroundColor(Color("Text"))
            .frame(width: DrawingConstants.progressCircleSize, height: DrawingConstants.progressCircleSize)
            .padding(.trailing)
            .onTapGesture {
                Haptics.shared.play(.medium)
                taskManager.toggleCompleted(task)
            }
        }
    }
    
    private struct DrawingConstants {
        static let progressCircleSize: CGFloat = 30
        static let topTaskBackgroundColor: Color = Color("Accent1")
        static let defaultTaskBackgroundColor: Color = Color("Accent2").opacity(0.3)
        static let completeTaskBackgroundColor: Color = Color.green.opacity(0.5)
        static let topTaskMinHeight: CGFloat = 150
        static let containerCornerRadius: CGFloat = 12
        static let progressCircleStrokeWidth: CGFloat = 2
    }
}
