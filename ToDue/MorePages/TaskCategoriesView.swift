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
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                showingAlert = true
                                toBeDeleted = category
                            }, label: {
                                Label("Delete", systemImage: "trash")
                            })
                            .tint(.red)
                        }
                    .themedListRowBackground()
                }
                .confirmationDialog(
                    Text("""
                         Are you sure you want to delete this?
                         All related tasks will be deleted aswell.
                         """),
                    isPresented: $showingAlert,
                    titleVisibility: .visible
                ) {
                    Button("Delete", role: .destructive) {
                        if let delete = toBeDeleted {
                            withAnimation(.easeInOut) {
                                manager.deleteCategory(delete)
                            }
                        }
                    }
                } message: {
                    Text(toBeDeleted?.categoryTitle ?? "")
                }
            }
            Section {
                HStack {
                    Spacer()
                    Button("Add category") {
                        categoryEditor = TaskCategoryEditor()
                        showAddCategory = true
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
                .themedListRowBackground()
            }
        }
        .sheet(isPresented: $showAddCategory) {
            NavigationView {
                Form {
                    TextField("Title", text: $categoryEditor.title)
                        .themedListRowBackground()
                }
                .navigationTitle("Add category")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color("Background"))
                .scrollContentBackground(.hidden)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showAddCategory = false
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            manager.saveCategory(categoryEditor)
                            showAddCategory = false
                        }
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .background(Color("Background"))
        .scrollContentBackground(.hidden)
        .navigationTitle("Task categories")
    }
}

struct TaskCategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCategoriesView()
    }
}
