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
    @State private var showEmail = false
    @State private var email = ContactEmail(toAddress: "contact@niklas-kuder.de", subject: "App contact inquiry", messageHeader: "Please enter your message below")
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
            .sheet(isPresented: $showEmail) {
                MailView(supportEmail: $email) { result in
                    switch result {
                    case .success:
                        return
                    case .failure(let error):
                        print(error)
                        return
                    }
                }
            }
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
            NavigationLink(destination: FAQView()) {
                Label("FAQ", systemImage: "questionmark.circle.fill")
                    .foregroundColor(Color("Text"))
            }
            Button {
                if MailView.canSendMail {
                    showEmail.toggle()
                } else {
                    print("""
                    This device does not support email
                    \(email.body)
                    """
                    )
                }
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
