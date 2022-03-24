//
//  TaskDetailView.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.22.
//

import SwiftUI

// TODO: DELETE THIS LATER
struct SubTask : Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
}
//

struct TaskDetailView: View {
    @Binding var showDetail: Bool
    @State var showContents: Bool = false
    // Used for swipe to delete
    @State private var offsets = [CGSize](repeating: CGSize.zero, count: 3)
    // TODO: DELETE THIS LATER
    @State var subTaskCompleted: Bool = false
    //
    var namespace: Namespace.ID
    let task: Task
    @State var subTasks = [SubTask(id: UUID(), title: "Test1", isCompleted: false), SubTask(id: UUID(), title: "Test2", isCompleted: false), SubTask(id: UUID(), title: "Test3", isCompleted: false)]
    
    var body: some View {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
                .matchedGeometryEffect(id: "background_\(task.id!)", in: namespace)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            ScrollView {
                HStack (alignment: .center) {
                    VStack(alignment: .leading) {
                        Text(dateFormatter.string(from: task.date ?? Date.now))
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matchedGeometryEffect(id: "date_\(task.id!)", in: namespace)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(task.taskDescription ?? "")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .matchedGeometryEffect(id: "description_\(task.id!)", in: namespace)
                            .font(.title)
                            .foregroundColor(Color("Text"))
                    }
                    .padding()
                    if showContents {
                        Divider()
                            .padding(.vertical)
                        Button {
                            // TODO: Implement edit functionality
                            print("Edit")
                        } label: {
                            Label("", systemImage: "pencil")
                                .scaleEffect(1.3)
                        }
                        .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
                if showContents {
                    VStack (alignment: .leading) {
                        ProgressBar(progress: 0.7)
                            .padding(.bottom, 20)
                        HStack (alignment: .bottom) {
                            Text("Sub-Tasks:")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                // TODO: Implement this
                            } label: {
                                Label("Add Sub-Task", systemImage: "plus")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        ForEach (subTasks.indices, id: \.self) { index in
                            HStack {
                                Text(subTasks[index].title)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.leading)
                                Spacer()
                                Image(systemName: subTaskCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title)
                                    .frame(width: 50, height: 50)
                                    .padding(.trailing)
                                    .onTapGesture {
                                        Haptics.shared.play(.medium)
                                        subTaskCompleted.toggle()
                                    }
                            }
                            .background(RoundedRectangle(cornerRadius: 15).fill(Color("Accent1")))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    Spacer()
                    Button{
                        closeDetailView()
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding()
                    }
                    .buttonStyle(RoundedRectangleButtonStyle(isDisabled: false))
                    .disabled(false)
                    .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeInOut.delay(0.3)) {
                showContents = true
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
            print("Delete")
    }
    
    func closeDetailView() {
        withAnimation(.spring()) {
            showDetail.toggle()
        }
    }
}
