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
        return ZStack {
            containerBackground
            HStack {
                VStack(alignment: .leading) {
                    Text(Utils.dateFormatter.string(from: task.date ?? Date.now))
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
        .confirmationDialog(
            Text("Are you sure you want to delete this?"),
            isPresented: $showingAlert,
            titleVisibility: .visible
        ) {
             Button("Delete", role: .destructive) {
                 withAnimation(.easeInOut) {
                     taskManager.deleteTask(task)
                 }
             }
        } message: {
            Text(task.taskTitle ?? "")
                .font(.headline).fontWeight(.bold)
        }
        .contextMenu {
            Button(role: .cancel, action: {
                taskManager.toggleCompleted(task)
            }, label: {
                Label(task.isCompleted ? "Mark as incomplete" : "Mark as complete", systemImage: task.isCompleted ? "checkmark.circle" : "checkmark.circle.fill")
            })
            Button(role: .destructive, action: {
                showingAlert = true
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
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
        static let topTaskMinHeight: CGFloat = 150
        static let containerCornerRadius: CGFloat = 12
        static let progressCircleStrokeWidth: CGFloat = 2
    }
}
