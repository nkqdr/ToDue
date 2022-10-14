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
    @State private var currentCategory: TaskCategory? = nil
    
    func launchEditCategory(_ category: TaskCategory) {
        currentCategory = category
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
                        currentCategory = nil
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
            AddTaskCategoryView(isOpen: $showAddCategory, categoryEditor: TaskCategoryEditor(currentCategory))
        }
        .onChange(of: showAddCategory) { newValue in
            if !newValue {
                currentCategory = nil
            }
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
