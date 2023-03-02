//
//  SubtaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 14.09.22.
//

import SwiftUI

struct SubtaskView: View {
    @EnvironmentObject private var taskManager: TaskManager
    @State private var showingAlert: Bool = false
    var subTask: SubTask
    var disableDelete: Bool = false
    var onEdit: ((SubTask) -> Void)?
    
    var body: some View {
        let subtaskIsInDaily: Bool = subTask.scheduledDate?.isSameDayAs(Date()) ?? false
        
        SubtaskContainer(title: subTask.title ?? "", isCompleted: subTask.isCompleted) {
            Haptics.shared.play(.medium)
            taskManager.toggleCompleted(subTask)
        }
        .versionAwareDeleteSwipeAction(showContextMenuInstead: false) {
            showingAlert = true
        }
        .versionAwareSubtaskCompleteSwipeAction(subTask) {
                taskManager.toggleCompleted(subTask)
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
                if subtaskIsInDaily {
                    taskManager.removeFromDaily(subTask)
                } else {
                    taskManager.addToDaily(subTask)
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
            onDelete: { taskManager.deleteTask(subTask) },
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
}

struct SubtaskView_Previews: PreviewProvider {
    static var previews: some View {
        SubtaskView(subTask: SubTask()) { subTask in
            print(subTask)
        }
    }
}
