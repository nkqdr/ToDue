//
//  ProgressBar.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.22.
//

import SwiftUI

struct ProgressBar: View {
    // Progress from 0 to 1
    var progress: Double
    var showPercentage: Bool = true
    
    var body: some View {
        GeometryReader { proxy in
            VStack (alignment: .trailing) {
                if showPercentage {
                    let formatted = String(format: "%.1f", progress * 100)
                    Text("\(formatted)%")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                ZStack (alignment: .leading) {
                    Capsule()
                        .fill(.ultraThickMaterial)
                        .frame(maxWidth: .infinity)
                    Capsule()
                        .fill(.blue)
                        .frame(maxWidth: proxy.size.width * progress)
                        .animation(.easeInOut, value: progress)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 10)
            }
        }
        .padding(.bottom, 10)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(progress: 0.7)
    }
}
