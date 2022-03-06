//
//  TaskContainer.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct TaskContainer: View {
    @EnvironmentObject var coreDM: CoreDataManager
    var openDetailView: () -> Void
    var namespace: Namespace.ID
    var task: Task
    var showBackground: Bool
    var onUpdate: () -> Void
    @State private var isCompleted = false
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return ZStack {
            if showBackground && !task.isCompleted {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color("Accent1"))
                    .matchedGeometryEffect(id: "background_\(task.id!)", in: namespace)
            } else {
                RoundedRectangle(cornerRadius: 15)
                .fill(
                    Color("Accent2")
                        .opacity(0.3)
                )
                .matchedGeometryEffect(id: "background_\(task.id!)", in: namespace)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(dateFormatter.string(from: task.date ?? Date.now))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .matchedGeometryEffect(id: "date_\(task.id!)", in: namespace)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .padding(.top)
                    Text(task.taskDescription ?? "")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .matchedGeometryEffect(id: "description_\(task.id!)", in: namespace)
                        .font(showBackground ? .title : .title2)
                        .foregroundColor(Color("Text"))
                        .padding(.horizontal)
                        .padding(.bottom)
                    Spacer()
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
        }
        .frame(minHeight: showBackground && !task.isCompleted ? 150 : 0)
        .contextMenu(menuItems: {
            Button(role: .cancel, action: {
                markSelfAsCompleted()
            }, label: {
                Label("Mark as \(task.isCompleted ? "uncompleted" : "completed")", systemImage: task.isCompleted ? "checkmark.circle" : "checkmark.circle.fill")
            })
            if !task.isCompleted {
                Button(role: .cancel, action: {
                    openDetailView()
                }, label: {
                    Label("Edit", systemImage: "pencil")
                })
            }
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
        isCompleted = !task.isCompleted
        coreDM.updateTask(task: task, isCompleted: isCompleted)
        onUpdate()
    }
}
