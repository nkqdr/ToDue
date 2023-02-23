//
//  SubtaskContainer.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.02.23.
//

import SwiftUI

struct SubtaskContainer: View {
    var title: String
    var isCompleted: Bool
    var progress: Double = 0
    var onToggleComplete: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .strikethrough(isCompleted, color: Color("Text"))
                .padding(.vertical, 15)
            Spacer()
            ProgressCircle(isCompleted: isCompleted, progress: progress, onTap: onToggleComplete)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .listRowInsets(DrawingConstants.subTaskListRowInsets)
    }
    
    private struct DrawingConstants {
        static let subTaskListRowInsets: EdgeInsets = EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
    }
}
