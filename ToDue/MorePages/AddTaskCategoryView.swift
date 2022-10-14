//
//  AddTaskCategoryView.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.10.22.
//

import SwiftUI

struct AddTaskCategoryView: View {
    @ObservedObject private var manager: TaskCategoryManager = TaskCategoryManager.shared
    @Binding var isOpen: Bool
    @ObservedObject var categoryEditor: TaskCategoryEditor
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Title", text: $categoryEditor.title)
                    .themedListRowBackground()
                Section(header: Text("Background color")) {
                    Toggle("Use default color", isOn: $categoryEditor.useDefaultColor)
                    if !categoryEditor.useDefaultColor {
                        ColorPicker("Category color", selection: $categoryEditor.categoryColor, supportsOpacity: false)
                    }
                }
                .themedListRowBackground()
            }
            .navigationTitle(categoryEditor.category != nil ? "Edit category" : "Add category")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color("Background").ignoresSafeArea())
            .hideScrollContentBackgroundIfNecessary()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isOpen.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        manager.saveCategory(categoryEditor)
                        isOpen.toggle()
                    }
                }
            }
        }
        .versionAwarePresentationDetents()
    }
}

struct AddTaskCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        AddTaskCategoryView(isOpen: .constant(true), categoryEditor: TaskCategoryEditor())
    }
}
