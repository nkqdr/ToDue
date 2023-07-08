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
        ZStack {
            List {
                if manager.categories.isEmpty {
                    HStack {
                        Spacer()
                        Text("Add a category in order to better manage your deadlines!")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color("Background"))
                    .padding(.top, 50)
                }
                Section {
                    ForEach($manager.categories) { $category in
                        TaskCategoryView(category: category, onEdit: launchEditCategory)
                    }
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
            
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(content: "Add category", systemImage: "plus") {
                        currentCategory = nil
                        showAddCategory.toggle()
                    }
                }
            }
        }
    }
}

struct TaskCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCategoriesView()
    }
}
