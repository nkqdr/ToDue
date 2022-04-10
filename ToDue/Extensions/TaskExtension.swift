//
//  TaskExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 10.04.22.
//

extension SubTask {
    public var wrappedTitle: String {
        title ?? "SubTask"
    }
}

extension Task {
    public var subTaskArray: [SubTask] {
        let set = subTasks as? Set<SubTask> ?? []
        
        return set.sorted {
            $0.wrappedTitle < $1.wrappedTitle
        }
    }
}
