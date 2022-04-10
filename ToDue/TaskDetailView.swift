//
//  TaskDetailView.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.22.
//

import SwiftUI

struct TaskDetailView: View {
    @EnvironmentObject var coreDM: CoreDataManager
    @Binding var showDetail: Bool
    @State var showContents: Bool = false
    // Used for swipe to delete
    @State private var offsets = [CGSize](repeating: CGSize.zero, count: 3)
    // TODO: DELETE THIS LATER
    @State var subTaskCompleted: Bool = false
    //
    var namespace: Namespace.ID
    var task: Task
    
//    init(showDetail: Binding<Bool>, namespace: Namespace.ID, task: Task) {
//        self._showDetail = showDetail
//        self.namespace = namespace
//        self.task = task
//    }
    
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
                            coreDM.removeAllSubTasks(from: task)
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
                                addSubTask(title: "Test")
                            } label: {
                                Label("Add", systemImage: "plus")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        ForEach (task.subTaskArray) { subTask in
                            HStack {
                                Text(subTask.title!)
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
    
    func addSubTask(title: String) {
        coreDM.addSubTask(to: task, subTaskTitle: title)
//        subTasks = task.subTaskArray
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
