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
    
    func launchEditCategory(category: TaskCategory) {
        categoryEditor = TaskCategoryEditor(category)
        print(category)
        showAddCategory.toggle()
    }
    
    var body: some View {
        List {
            Section {
                ForEach($manager.categories) { $category in
                    TaskCategoryView(category: category, onEdit: launchEditCategory)
                }
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
        .sheet(isPresented: $showAddCategory, onDismiss: {
            categoryEditor = TaskCategoryEditor()
        }) {
            AddTaskCategoryView(categoryEditor: categoryEditor, isOpen: $showAddCategory)
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
