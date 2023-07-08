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
    @StateObject private var singleTaskManager: SingleTaskManager
    var task: Task
    var showBackground: Bool = false
    var cornerRadius: Double = DrawingConstants.containerCornerRadius
    
    init(task: Task, showBackground: Bool = false, cornerRadius: Double = DrawingConstants.containerCornerRadius) {
        self.task = task
        self._singleTaskManager = StateObject(wrappedValue: SingleTaskManager(task: task))
        self.showBackground = showBackground
        self.cornerRadius = cornerRadius
    }
    
    @ViewBuilder
    private var taskDateText: some View {
        Group {
            Text(Utils.dateFormatter.string(from: task.date ?? Date())) +
            Text(" • (") +
            Text(Utils.shortRemainingTimeLabel(task: task)) +
            Text(")")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.subheadline.weight(.semibold))
        .foregroundColor(.secondary)
    }
    
    var body: some View {
        let taskIsInDaily: Bool = task.scheduledDate?.isSameDayAs(Date()) ?? false
        return ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(containerBackgroundColor)
            HStack {
                VStack(alignment: .leading) {
                    if let date = task.date, date < Date.distantFuture {
                        taskDateText
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
                    if singleTaskManager.progress == 1 && !task.isCompleted {
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
            onDelete: { taskManager.delete(task) },
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
                        taskManager.unscheduleForToday(task)
                    } else {
                        taskManager.scheduleForToday(task)
                    }
                }
            } label: {
                Label(taskIsInDaily ? "Remove from today" : "Add to today", systemImage: taskIsInDaily ? "minus.circle" : "link.badge.plus")
            }
            VersionAwareDestructiveButton {
                showingAlert = true
            }
        }
    }
    
    var containerBackgroundColor: Color {
        if let category = task.category, !category.useDefaultColor, let color = category.wrappedColor {
            return color
        } else if singleTaskManager.progress == 1 {
            return DrawingConstants.completeTaskBackgroundColor
        } else if showBackground && !task.isCompleted {
            return DrawingConstants.topTaskBackgroundColor
        } else {
            return DrawingConstants.defaultTaskBackgroundColor
        }
    }
    
    @ViewBuilder
    var progressCircle: some View {
        ProgressCircle(isCompleted: task.isCompleted, progress: singleTaskManager.progress)
            .padding(.trailing)
            .onTapGesture {
                Haptics.shared.play(.medium)
                taskManager.toggleCompleted(task)
            }
    }
    
    private struct DrawingConstants {
        static let topTaskBackgroundColor: Color = Color("Accent1")
        static let defaultTaskBackgroundColor: Color = Color("Accent2").opacity(0.3)
        static let completeTaskBackgroundColor: Color = Color("CompleteTask")
        static let topTaskMinHeight: CGFloat = 140
        static let containerCornerRadius: CGFloat = 12
    }
}
