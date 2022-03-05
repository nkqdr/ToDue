//
//  TaskContainer.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct TaskContainer: View {
    @EnvironmentObject var coreDM: CoreDataManager
    var task: Task
    var geometry: GeometryProxy
    var showBackground: Bool
    var onUpdate: () -> Void
    @State private var isCompleted = false
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return HStack {
            VStack(alignment: .leading) {
                Text(dateFormatter.string(from: task.date ?? Date.now))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Text"))
                    .padding(.horizontal)
                    .padding(.top)
                Spacer()
                Text(task.taskDescription ?? "")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("Text"))
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            Spacer()
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.largeTitle)
                .frame(width: 50, height: 50)
                .padding(.trailing)
                .onTapGesture {
                    markSelfAsCompleted()
                }
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
        .background(
            showBackground ? RoundedRectangle(cornerRadius: 15)
                .fill(Color("Accent1")) : RoundedRectangle(cornerRadius: 15)
                .fill(Color("Accent2").opacity(0.3))
            )
        .contextMenu(menuItems: {
            Button(role: .cancel, action: {
                markSelfAsCompleted()
            }, label: {
                Label("Mark as completed", systemImage: "checkmark.circle.fill")
            })
            Button(role: .cancel, action: {
                print("Edit")
            }, label: {
                Label("Edit", systemImage: "pencil")
            })
            // Disabled because it is not implemented yet.
            .disabled(true)
            Button(role: .destructive, action: {
                coreDM.deleteTask(task: task)
                onUpdate()
            }, label: {
                Label("Delete", systemImage: "trash")
            })
        })
        .padding(.bottom)
    }
    
    func markSelfAsCompleted() {
        print("Completing..")
        isCompleted = !task.isCompleted
        coreDM.updateTask(task: task, isCompleted: isCompleted)
        onUpdate()
    }
}
