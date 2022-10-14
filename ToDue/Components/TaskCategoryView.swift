//
//  TaskCategoryView.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.09.22.
//

import SwiftUI

struct TaskCategoryView: View {
    @ObservedObject private var manager: TaskCategoryManager = TaskCategoryManager.shared
    var category: TaskCategory
    var onEdit: (TaskCategory) -> Void
    @State private var showingAlert: Bool = false
    
    var body: some View {
        HStack {
            Text(category.categoryTitle ?? "")
            Spacer()
            Text("Tasks: \(category.taskArray.count)")
                .foregroundColor(.secondary)
                .font(.callout)
        }
        .versionAwareDeleteSwipeAction(showContextMenuInstead: false) {
            showingAlert = true
        }
        .versionAwareEditSwipeAction(showContextMenuInstead: false) {
            onEdit(category)
        }
        .contextMenu {
            Button {
                onEdit(category)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            VersionAwareDestructiveButton()
        }
        .themedListRowBackground()
        .versionAwareConfirmationDialog(
            $showingAlert,
            title: """
                 Are you sure you want to delete this?
                 All related tasks will be deleted aswell.
                 """,
            message: category.categoryTitle ?? "",
            onDelete: {
                manager.deleteCategory(category)
            }, onCancel: {
                showingAlert = false
            }
        )
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
}
