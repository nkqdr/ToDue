//
//  SettingsView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct SettingsView: View {
    @State private var toggle = false
//    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Hello Settings!")
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("Background"))
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
