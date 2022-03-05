//
//  SettingsView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct SettingsView: View {
    @State private var toggle = false
    @Binding var isPresented: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color("Text"))
                    Spacer()
                    Button("Close") {
                        isPresented = false
                    }
                }
                .padding(.top)
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(Color("Background"))
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(isPresented: .constant(true))
    }
}
