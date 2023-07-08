//
//  SubtaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 14.09.22.
//

import SwiftUI

struct SubtaskView: View {
    @EnvironmentObject private var taskManager: SingleTaskManager
    @State private var showingAlert: Bool = false
    var subTask: SubTask
    var disableDelete: Bool = false
    var onEdit: ((SubTask) -> Void)?
    
    var body: some View {
        let subtaskIsInDaily: Bool = subTask.scheduledDate?.isSameDayAs(Date()) ?? false
        let scheduledDateString: String? = subTask.scheduledDate != nil ? Utils.dateFormatter.string(from: subTask.scheduledDate!) : nil
        
        SubtaskContainer(title: subTask.wrappedTitle, isCompleted: subTask.isCompleted, topSubTitle: scheduledDateString) {
            Haptics.shared.play(.medium)
            withAnimation {
                taskManager.toggleCompleted(subTask)
            }
        }
        .versionAwareSubtaskDeleteSwipeAction(labelText: "Delete", labelImage: "trash") {
            showingAlert = true
        }
        .versionAwareSubtaskCompleteSwipeAction(subTask) {
            withAnimation {
                taskManager.toggleCompleted(subTask)
            }
        }
        .versionAwareSubtaskEditSwipeAction(labelText: "Edit", labelImage: "pencil", enabled: onEdit != nil) {
            if let editFunc = onEdit {
                editFunc(subTask)
            }
        }
        .contextMenu {
            if let edit = onEdit {
                Button {
                    edit(subTask)
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            Button {
                withAnimation {
                    if subtaskIsInDaily {
                        taskManager.unscheduleForToday(subTask)
                    } else {
                        taskManager.scheduleForToday(subTask)
                    }
                }
            } label: {
                Label(subtaskIsInDaily ? "Remove from today" : "Add to today", systemImage: subtaskIsInDaily ? "minus.circle" : "link.badge.plus")
            }
            VersionAwareDestructiveButton()
        }
        .versionAwareConfirmationDialog(
            $showingAlert,
            title: "Are you sure you want to delete this?",
            message: subTask.wrappedTitle,
            onDelete: { taskManager.delete(subTask) },
            onCancel: { showingAlert = false })
        .listRowInsets(DrawingConstants.subTaskListRowInsets)
    }
    
    @ViewBuilder
    private func VersionAwareDestructiveButton() -> some View {
        if disableDelete {
            EmptyView()
        } else if #available(iOS 15.0, *) {
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
    
    private struct DrawingConstants {
        static let subTaskListRowInsets: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
}

fileprivate extension View {
    func versionAwareSubtaskEditSwipeAction(labelText: LocalizedStringKey, labelImage: String, enabled: Bool = true, onEdit: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.versionAwareSwipeAction(labelText: labelText, labelImage: labelImage, tint: .indigo, leading: true, perform: onEdit)
        } else {
            return self
        }
    }
    
    func versionAwareSubtaskDeleteSwipeAction(labelText: LocalizedStringKey, labelImage: String, enabled: Bool = true, onDelete: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.versionAwareSwipeAction(labelText: labelText, labelImage: labelImage, tint: .red, perform: onDelete)
        } else {
            return self
        }
    }
}
