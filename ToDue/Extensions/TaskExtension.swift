//
//  TaskExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 10.04.22.
//

import Foundation

extension SubTask {
    public var wrappedTitle: String {
        title ?? "SubTask"
    }
    
    public var wrappedCreatedAt: Date {
        createdAt ?? Date.now
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
