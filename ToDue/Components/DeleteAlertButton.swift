//
//  DeleteAlertButton.swift
//  ToDue
//
//  Created by Niklas Kuder on 16.08.22.
//

import SwiftUI

struct DeleteAlertButton: View {
    @Binding var showingAlert: Bool
    var onDelete: () -> Void
    
    var body: some View {
        Button(role: .destructive, action: {
            showingAlert = true
        }, label: {
            Label("Delete", systemImage: "trash")
        })
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Are you sure you want to delete this?"),
                message: Text("There is no undo"),
                primaryButton: .destructive(Text("Delete"), action: onDelete),
                secondaryButton: .cancel()
            )
        }
    }
}
