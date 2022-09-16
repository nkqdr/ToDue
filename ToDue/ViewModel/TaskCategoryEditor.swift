//
//  TaskCategoryEditor.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.09.22.
//

import Foundation

class TaskCategoryEditor: ObservableObject, Identifiable {
    var id = UUID()
    @Published var title: String = ""
    
    var category: TaskCategory?
}
