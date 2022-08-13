//
//  ToDueApp.swift
//  ToDue
//
//  Created by Niklas Kuder on 04.03.22.
//

import SwiftUI

@main
struct ToDueApp: App {
    @StateObject var coreDM = CoreDataManager.shared
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
            }
            .environmentObject(coreDM)
        }
    }
}
