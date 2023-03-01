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
    var cornerRadius: Double = DrawingConstants.containerCornerRadius
    
    var body: some View {
        let taskIsInDaily: Bool = task.dailyTask?.isSameDayAs(Date()) ?? false
        return ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(containerBackgroundColor)
            HStack {
                VStack(alignment: .leading) {
                    if let date = task.date, date < Date.distantFuture {
                        Text(Utils.dateFormatter.string(from: task.date ?? Date()))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Text(task.taskTitle ?? "")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(showBackground && !task.isCompleted ? .title3 : .headline)
                        .foregroundColor(Color("Text"))
                    if let desc = task.taskDescription {
                        Text(desc)
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    Spacer()
                    if taskManager.progress(for: task) == 1 && !task.isCompleted {
                        Text("Complete this task by tapping the circle!")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .multilineTextAlignment(.leading)
                .padding()
                Spacer()
                progressCircle
            }
        }
        .frame(minHeight: showBackground && !task.isCompleted ? DrawingConstants.topTaskMinHeight : 0)
        .versionAwareConfirmationDialog(
            $showingAlert,
            title: "Are you sure you want to delete this?",
            message: task.taskTitle ?? "",
            onDelete: { taskManager.deleteTask(task) },
            onCancel: { showingAlert = false })
        .contextMenu {
            Button(action: {
                taskManager.toggleCompleted(task)
            }, label: {
                Label(task.isCompleted ? "Mark as incomplete" : "Mark as complete", systemImage: task.isCompleted ? "checkmark.circle" : "checkmark.circle.fill")
            })
            Button {
                withAnimation {
                    if taskIsInDaily {
                        taskManager.removeFromDaily(task)
                    } else {
                        taskManager.addToDaily(task)
                    }
                }
            } label: {
                Label(taskIsInDaily ? "Remove from today" : "Add to today", systemImage: taskIsInDaily ? "minus.circle" : "link.badge.plus")
            }
            VersionAwareDestructiveButton()
        }
    }
    
    @ViewBuilder
    private func VersionAwareDestructiveButton() -> some View {
        if #available(iOS 15.0, *) {
            Button(role: .destructive, action: {
                showingAlert = true
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        } else {
            Button(action: {
                showingAlert = true
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
    }
    
    var containerBackgroundColor: Color {
        if let category = task.category, !category.useDefaultColor, let color = category.wrappedColor {
            return color
        } else if taskManager.progress(for: task) == 1 {
            return DrawingConstants.completeTaskBackgroundColor
        } else if showBackground && !task.isCompleted {
            return DrawingConstants.topTaskBackgroundColor
        } else {
            return DrawingConstants.defaultTaskBackgroundColor
        }
    }
    
    @ViewBuilder
    var progressCircle: some View {
        ProgressCircle(isCompleted: task.isCompleted, progress: taskManager.progress(for: task)) {
            Haptics.shared.play(.medium)
            taskManager.toggleCompleted(task)
        }
        .padding(.trailing)
    }
    
    private struct DrawingConstants {
        static let topTaskBackgroundColor: Color = Color("Accent1")
        static let defaultTaskBackgroundColor: Color = Color("Accent2").opacity(0.3)
        static let completeTaskBackgroundColor: Color = Color("CompleteTask")
        static let topTaskMinHeight: CGFloat = 140
        static let containerCornerRadius: CGFloat = 12
    }
}
