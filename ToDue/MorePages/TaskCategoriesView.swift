//
//  TaskCategoriesView.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.09.22.
//

import SwiftUI

struct TaskCategoriesView: View {
    @ObservedObject private var manager: TaskCategoryManager = TaskCategoryManager.shared
    @State private var showingAlert: Bool = false
    @State private var showAddCategory: Bool = false
    @State private var categoryEditor: TaskCategoryEditor = TaskCategoryEditor()
    @State private var toBeDeleted: TaskCategory?
    
    var body: some View {
        List {
            Section {
                ForEach($manager.categories) { $category in
                    HStack {
                        Text(category.categoryTitle ?? "")
                        Spacer()
                        Text("Tasks: \(category.taskArray.count)")
                            .foregroundColor(.secondary)
                            .font(.callout)
                    }
                    .versionAwareDeleteSwipeAction {
                        showingAlert = true
                        toBeDeleted = category
                    }
                    .themedListRowBackground()
                }
                .versionAwareConfirmationDialog(
                    $showingAlert,
                    title: """
                         Are you sure you want to delete this?
                         All related tasks will be deleted aswell.
                         """,
                    message: toBeDeleted?.categoryTitle ?? "",
                    onDelete: {
                        if let delete = toBeDeleted {
                            manager.deleteCategory(delete)
                        }
                    }, onCancel: {
                        showingAlert = false
                    })
            }
            Section {
                HStack {
                    Spacer()
                    Button("Add category") {
                        categoryEditor = TaskCategoryEditor()
                        showAddCategory.toggle()
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
                .themedListRowBackground()
            }
        }
        .groupListStyleIfNecessary()
        .sheet(isPresented: $showAddCategory) {
            NavigationView {
                Form {
                    TextField("Title", text: $categoryEditor.title)
                        .themedListRowBackground()
                }
                .navigationTitle("Add category")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color("Background").ignoresSafeArea())
                .hideScrollContentBackgroundIfNecessary()
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showAddCategory.toggle()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            manager.saveCategory(categoryEditor)
                            showAddCategory.toggle()
                        }
                    }
                }
            }
            .versionAwarePresentationDetents()
        }
        .background(Color("Background").ignoresSafeArea())
        .hideScrollContentBackgroundIfNecessary()
        .navigationTitle("Task categories")
    }
}

struct TaskCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCategoriesView()
    }
}
