//
//  FAQView.swift
//  ToDue
//
//  Created by Niklas Kuder on 26.08.22.
//

import SwiftUI

struct FAQView: View {
    var body: some View {
        List {
            Group {
                overviewSection
                subTasksSection
            }
            .listRowBackground(Color("Accent2").opacity(0.3))
        }
        .navigationTitle("FAQ")
        .background(Color("Background"))
    }
    
    var overviewSection: some View {
        Section("Overview") {
            DisclosureGroup {
                Text("If you press and hold a task for a short time, several functions are displayed. There you can also delete them, among other things.")
                    .foregroundColor(.secondary)
            } label: {
                Text("How can I delete a task?")
                    .frame(minHeight: 40)
            }
            DisclosureGroup {
                Text("First tap on a task to select it. Then you will see a pen in the upper right corner that you can tap on. Now you are in 'Edit' mode and can make additional notes.")
                    .foregroundColor(.secondary)
            } label: {
                Text("How can I write down additional information about a task?")
                    .frame(minHeight: 80)
            }
            DisclosureGroup {
                Text("The tasks are sorted by their due date, so you will always see the next task at the top.")
                    .foregroundColor(.secondary)
            } label: {
                Text("In what order are the tasks listed?")
                    .frame(minHeight: 50)
            }
        }
    }
    
    var subTasksSection: some View {
        Section("Sub-Tasks") {
            DisclosureGroup {
                Text("First tap on a task to select it. Now you should see a button that says 'Add subtask'.")
                    .foregroundColor(.secondary)
            } label: {
                Text("How can I add subtasks?")
                    .frame(minHeight: 50)
            }
        }
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}
