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
    var onEdit: (SubTask) -> Void
    
    var body: some View {
        HStack {
            Text(subTask.title ?? "")
                .font(.headline)
                .fontWeight(.bold)
                .strikethrough(subTask.isCompleted, color: Color("Text"))
            Spacer()
            Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title)
                .frame(width: DrawingConstants.completeIndicatorSize, height: DrawingConstants.completeIndicatorSize)
                .onTapGesture {
                    Haptics.shared.play(.medium)
                    taskManager.toggleCompleted(subTask)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .versionAwareDeleteSwipeAction(showContextMenuInstead: false) {
            showingAlert = true
        }
        .versionAwareSubtaskCompleteSwipeAction(
            labelText: subTask.isCompleted ? "Mark as incomplete" : "Mark as complete",
            labelImage: subTask.isCompleted ? "gobackward.minus" : "checkmark.circle.fill") {
                taskManager.toggleCompleted(subTask)
            }
            .versionAwareSubtaskEditSwipeAction(labelText: "Edit", labelImage: "pencil") {
                onEdit(subTask)
            }
        .contextMenu {
            Button {
                onEdit(subTask)
            } label: {
                Label("Edit", systemImage: "pencil")
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
    
    private struct DrawingConstants {
        static let completeIndicatorSize: CGFloat = 50
        static let subTaskListRowInsets: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
}

fileprivate extension View {
    func versionAwareSubtaskCompleteSwipeAction(labelText: LocalizedStringKey, labelImage: String, onComplete: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.swipeActions(edge: .leading) {
                Button {
                    onComplete()
                } label: {
                    Label(labelText, systemImage: labelImage)
                }
                .tint(.mint)
            }
        } else {
            return self
        }
    }
    
    func versionAwareSubtaskEditSwipeAction(labelText: LocalizedStringKey, labelImage: String, onEdit: @escaping () -> Void) -> some View {
        if #available(iOS 15.0, *) {
            return self.swipeActions(edge: .leading) {
                Button {
                    onEdit()
                } label: {
                    Label(labelText, systemImage: labelImage)
                }
                .tint(.indigo)
            }
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
