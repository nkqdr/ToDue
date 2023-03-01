//
//  FloatingActionButton.swift
//  ToDue
//
//  Created by Niklas Kuder on 01.03.23.
//

import SwiftUI

struct FloatingActionButton: View {
    var content: LocalizedStringKey
    var systemImage: String
    var backgroundColor: Color?
    var perform: () -> Void
    
    var body: some View {
        Button(action: perform, label: {
            Label(content, systemImage: systemImage)
                .font(.subheadline.bold())
                .foregroundColor(Color.white)
                .padding()
        })
        .background(backgroundColor ?? Color.blue)
        .cornerRadius(50)
        .padding()
        .shadow(color: Color.black.opacity(0.3),
                radius: 3,
                x: 3,
                y: 3)
    }
}
