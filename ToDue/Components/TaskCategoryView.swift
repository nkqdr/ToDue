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
    @State private var showingAlert: Bool = false
    
    var body: some View {
        HStack {
            Text(category.categoryTitle ?? "")
            Spacer()
            Text("Tasks: \(category.taskArray.count)")
                .foregroundColor(.secondary)
                .font(.callout)
        }
        .versionAwareDeleteSwipeAction {
            showingAlert = true
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
            })
    }
}
