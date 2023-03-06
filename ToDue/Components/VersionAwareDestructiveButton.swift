//
//  VersionAwareDestructiveButton.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.23.
//

import SwiftUI

struct VersionAwareDestructiveButton: View {
    var action: () -> Void
    
    var body: some View {
        if #available(iOS 15.0, *) {
            Button(role: .destructive, action: action, label: {
                Label("Delete", systemImage: "trash")
            })
        } else {
            Button(action: action, label: {
                Label("Delete", systemImage: "trash")
            })
        }
    }
}

