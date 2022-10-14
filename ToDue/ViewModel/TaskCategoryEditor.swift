//
//  TaskCategoryEditor.swift
//  ToDue
//
//  Created by Niklas Kuder on 15.09.22.
//

import Foundation
import SwiftUI

class TaskCategoryEditor: ObservableObject, Identifiable {
    var id = UUID()
    @Published var title: String = ""
    @Published var useDefaultColor: Bool = false
    @Published var categoryColor: Color = .white
    
    var category: TaskCategory?
    
    init(_ category: TaskCategory?) {
        self.category = category
        self.title = category?.categoryTitle ?? ""
        self.useDefaultColor = category?.useDefaultColor ?? false
        self.categoryColor = category?.wrappedColor ?? .white
    }
    
    init() {}
}
