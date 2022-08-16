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
        WindowGroup {
            ZStack {
                ContentView()
            }
            .environmentObject(taskManager)
        }
    }
}
