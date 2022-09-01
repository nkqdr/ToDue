//
//  ToDueApp.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

@main
struct ToDueApp: App {
    @StateObject var taskManager = TaskManager()
    
    var body: some Scene {
        UITableView.appearance().backgroundColor = .clear
        return WindowGroup {
            TabView {
                IncompleteTaskView()
                    .tabItem {
                        Image(systemName: "checklist")
                        Text("Overview")
                    }
                CompletedTasksView()
                    .tabItem {
                        Image(systemName: "rectangle.fill.badge.checkmark")
                        Text("Completed")
                    }
                MorePageView()
                    .tabItem {
                        Image(systemName: "ellipsis")
                        Text("More")
                    }
            }
            .environmentObject(taskManager)
            .environment(\.managedObjectContext, taskManager.container.viewContext)
        }
    }
}
