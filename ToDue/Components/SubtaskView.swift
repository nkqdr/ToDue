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
        .swipeActions(edge: .trailing) {
            Button(action: {
                showingAlert = true
            }, label: {
                Label("Delete", systemImage: "trash")
            })
            .tint(.red)
        }
        .swipeActions(edge: .leading) {
            Button {
                taskManager.toggleCompleted(subTask)
            } label: {
                Label(subTask.isCompleted ? "Mark as incomplete" : "Mark as complete", systemImage: subTask.isCompleted ? "gobackward.minus" : "checkmark.circle.fill")
            }
                .tint(.mint)
            Button {
                onEdit(subTask)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.indigo)
        }
        .contextMenu {
            Button {
                onEdit(subTask)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive, action: {
                showingAlert = true
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        }
        .confirmationDialog(
            Text("Are you sure you want to delete this?"),
            isPresented: $showingAlert,
            titleVisibility: .visible
        ) {
             Button("Delete", role: .destructive) {
                 withAnimation(.easeInOut) {
                     taskManager.deleteTask(subTask)
                 }
             }
            Button("Cancel", role: .cancel) {
                showingAlert = false
            }
        } message: {
            Text(subTask.wrappedTitle)
                .font(.headline).fontWeight(.bold)
        }
        .listRowInsets(DrawingConstants.subTaskListRowInsets)
    }
    
    private struct DrawingConstants {
        static let completeIndicatorSize: CGFloat = 50
        static let subTaskListRowInsets: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
}

struct SubtaskView_Previews: PreviewProvider {
    static var previews: some View {
        SubtaskView(subTask: SubTask()) { subTask in
            print(subTask)
        }
    }
}
