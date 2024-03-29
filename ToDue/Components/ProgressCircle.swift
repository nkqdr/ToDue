//
//  ProgressCircle.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.02.23.
//

import SwiftUI

struct ProgressCircle: View {
    var isCompleted: Bool
    var progress: Double
    var backgroundColor: Color = .clear
    
    var body: some View {
        if isCompleted {
            Image(systemName: "checkmark.circle.fill")
                .font(.title)
                .frame(width: DrawingConstants.progressCircleSize, height: DrawingConstants.progressCircleSize)
                .foregroundColor(Color("Text"))
        } else {
            ZStack {
                Circle()
                    .strokeBorder(lineWidth: DrawingConstants.progressCircleStrokeWidth)
                ProgressPie(progress: progress)
            }
            .animation(.easeInOut, value: progress)
            .foregroundColor(Color("Text"))
            .frame(width: DrawingConstants.progressCircleSize, height: DrawingConstants.progressCircleSize)
        }
    }
    
    private struct DrawingConstants {
        static let progressCircleSize: CGFloat = 30
        static let progressCircleStrokeWidth: CGFloat = 2
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircle(isCompleted: true, progress: 0.5)
    }
}
