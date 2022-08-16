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
    @Namespace var taskNamespace
    
    var body: some Scene {
        let tabBarAppearance = UITabBarAppearance.init(idiom: .unspecified)
//        tabBarAppearance.configureWithTransparentBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        return WindowGroup {
            TabView {
                IncompleteTaskView(taskNamespace: taskNamespace)
                    .tabItem {
                        Image(systemName: "checklist")
                        Text("Overview")
                    }
                CompletedTasksView(taskNamespace: taskNamespace)
                    .tabItem {
                        Image(systemName: "rectangle.fill.badge.checkmark")
                        Text("Completed")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
            .environmentObject(taskManager)
        }
    }
}
