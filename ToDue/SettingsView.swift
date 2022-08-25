//
//  SettingsView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.openURL) var openURL
    @State private var toggle = false
    enum AppTheme: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: Self { self }
    }

    @State private var selectedFlavor: AppTheme = .system
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    generalSettings
                    appearanceSettings
                    helpSettings
                    settingsFooter
                }
                .listRowBackground(Color("Accent2").opacity(0.3))
            }
            .background(Color("Background"))
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
    }
    
    var generalSettings: some View {
        Section("General") {
            NavigationLink("Something") {
                
            }
            NavigationLink("Something else") {
                
            }
        }
    }
    
    var appearanceSettings: some View {
        Section("Appearance") {
            Menu {
                Picker(selection: $selectedFlavor, label: Text("Select Theme")) {
                    ForEach(AppTheme.allCases) { appTheme in
                        Text(appTheme.rawValue.capitalized).tag(appTheme)
                    }
                }
            } label: {
                HStack {
                    Text("App Theme")
                        .foregroundColor(Color("Text"))
                    Spacer()
                    Text(selectedFlavor.rawValue.capitalized)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var helpSettings: some View {
        Section("Help") {
            NavigationLink(destination: EmptyView()) {
                Label("Some help", systemImage: "questionmark.circle.fill")
                    .foregroundColor(Color("Text"))
            }
            Button {
                let email = ContactEmail(toAddress: "contact@niklas-kuder.de", subject: "App contact inquiry", messageHeader: "Please enter your message below")
                email.send(openURL: openURL)
            } label: {
                Label("Contact", systemImage: "person.fill.questionmark")
            }
        }
    }
    
    var settingsFooter: some View {
        Section {
            HStack {
                Image(systemName: "heart")
                VStack(alignment: .leading) {
                    Text("Made with Love in Karlsruhe")
                    Text("Version 0.1.0")
                }
                .font(.footnote)
            }
            .foregroundColor(.secondary)
        }
    }
    
    func placeOrder() { }
    func adjustOrder() { }
    func cancelOrder() { }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .preferredColorScheme(.dark)
    }
}
