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
    
    private func checkNotificationPermissions() {
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus != .authorized {
                current.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        })
    }
    
    var body: some Scene {
        UITableView.appearance().backgroundColor = .clear
        checkNotificationPermissions()
        
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
        }
    }
}
