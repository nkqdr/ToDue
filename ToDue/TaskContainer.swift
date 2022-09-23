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
        return ZStack(alignment: .topTrailing) {
            containerBackground
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
//                    if let category = task.category {
//                        Text(category.categoryTitle ?? "")
//                            .font(.footnote)
//                            .padding(.vertical, 5)
//                            .padding(.horizontal, 10)
//                            .foregroundColor(.secondary)
//                            .background(.thinMaterial, in: Capsule())
//                    }
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
            VersionAwareDestructiveButton()
        }
        .padding(.bottom, 5)
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
            let progress = taskManager.progress(for: task)
            ZStack {
                // This circle is needed so that the TapGesture is also recognized within the stroked circle.
                Circle()
                    .foregroundColor(.clear)
                Circle()
                    .strokeBorder(lineWidth: DrawingConstants.progressCircleStrokeWidth)
                    .animation(.easeInOut, value: progress)
                ProgressPie(progress: progress)
                    .animation(.easeInOut, value: progress)
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
        static let topTaskMinHeight: CGFloat = 140
        static let containerCornerRadius: CGFloat = 12
        static let progressCircleStrokeWidth: CGFloat = 2
    }
}
