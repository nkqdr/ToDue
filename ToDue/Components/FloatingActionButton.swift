//
//  FloatingActionButton.swift
//  ToDue
//
//  Created by Niklas Kuder on 01.03.23.
//

import SwiftUI

struct FloatingActionButton: View {
    var content: LocalizedStringKey?
    var systemImage: String
    var backgroundColor: Color?
    var perform: () -> Void
    
    var body: some View {
        Button(action: perform, label: {
            Group {
                if let c = content {
                    Label(c, systemImage: systemImage)
                } else {
                    Image(systemName: systemImage)
                        .font(.title.bold())
                }
            }
            .font(.subheadline.bold())
            .foregroundColor(Color("Text"))
            .padding()
        })
        .background(backgroundColor ?? Color("Accent1"))
        .cornerRadius(50)
        .padding()
        .shadow(color: Color.black.opacity(0.3),
                radius: 4,
                x: 3,
                y: 3)
    }
}
