//
//  ToDueApp.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

@main
struct ToDueApp: App {
    @StateObject var taskManager = TaskManager.shared
    
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
                        if #available(iOS 15.0, *) {
                            Image(systemName: "checklist")
                        } else {
                            Image(systemName: "list.bullet")
                        }
                        Text("Overview")
                    }
                CompletedTasksView()
                    .tabItem {
                        Image(systemName: "rectangle.fill.badge.checkmark")
                        Text("Completed")
                    }
                MorePageView()
                    .tabItem {
                        if #available(iOS 15.0, *) {
                            Image(systemName: "ellipsis")
                        } else {
                            Image(systemName: "ellipsis.circle")
                        }
                        Text("More")
                    }
            }
            .environmentObject(taskManager)
        }
    }
}
