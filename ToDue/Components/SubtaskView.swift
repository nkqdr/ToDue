//
//  SubtaskView.swift
//  ToDue
//
//  Created by Niklas Kuder on 14.09.22.
//

import SwiftUI

struct SubtaskView: View {
    @EnvironmentObject private var taskManager: TaskManager
    var subTask: SubTask
    
    var body: some View {
        HStack {
            Text(subTask.title ?? "")
                .font(.headline)
                .fontWeight(.bold)
                .strikethrough(subTask.isCompleted, color: Color("Text"))
            Spacer()
            Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title)
                .frame(width: DrawingConstants.completeIndicatorSize, height: DrawingConstants.completeIndicatorSize)
                .onTapGesture {
                    Haptics.shared.play(.medium)
                    taskManager.toggleCompleted(subTask)
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(DrawingConstants.subTaskListRowInsets)
    }
    
    private struct DrawingConstants {
        static let completeIndicatorSize: CGFloat = 50
        static let subTaskListRowInsets: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
}

struct SubtaskView_Previews: PreviewProvider {
    static var previews: some View {
        SubtaskView(subTask: SubTask())
    }
}
