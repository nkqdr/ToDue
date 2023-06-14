//
//  TaskExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 10.04.22.
//

import Foundation
import SwiftUI

extension SubTask {
    public var wrappedTitle: String {
        title ?? ""
    }
    
    public var wrappedCreatedAt: Date {
        createdAt ?? Date()
    }
}

extension TaskCategory {
    public var taskArray: [Task] {
        let set = tasks as? Set<Task> ?? []
        
        return set.sorted {
            return $0.wrappedDate < $1.wrappedDate
        }
    }
}

extension TaskCategory {
    public var wrappedColor: Color? {
        if !self.useDefaultColor {
            return Color(red: self.categoryColorRed, green: self.categoryColorGreen, blue: self.categoryColorBlue)
        }
        return nil
    }
    
    public var useDefaultColor: Bool {
        if self.categoryColorRed > 0 || self.categoryColorGreen > 0 || self.categoryColorBlue > 0 {
            return false
        }
        return true
    }
}

extension Task {
    public var wrappedDate: Date {
        date ?? Date()
    }
    
    public var subTaskArray: [SubTask] {
        let set = subTasks as? Set<SubTask> ?? []
        
        return set.sorted {
            if $0.wrappedCreatedAt == $1.wrappedCreatedAt {
                return $0.wrappedTitle < $1.wrappedTitle
            }
            return $0.wrappedCreatedAt < $1.wrappedCreatedAt
        }
    }
}
