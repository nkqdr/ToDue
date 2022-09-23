//
//  MorePageView.swift
//  ToDue
//
//  Created by Niklas Kuder on 05.03.22.
//

import SwiftUI

struct MorePageView: View {
    @Environment(\.openURL) var openURL
    @State private var toggle = false
    @State private var showEmail = false
    @State private var email = ContactEmail(toAddress: "contact@niklas-kuder.de", subject: "App contact inquiry", messageHeader: "Please enter your message below")
    
    var body: some View {
        NavigationView {
            List {
                Group {
                    generalSettings
                    configurationSection
                    helpSection
                    pageFooter
                }
                .themedListRowBackground()
            }
            .background(Color("Background"))
            .hideScrollContentBackgroundIfNecessary()
            .navigationTitle("More")
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
        Section(header: Text("General")) {
            NavigationLink(destination: SettingsView()) {
                Label("Settings", systemImage: "gear")
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    var configurationSection: some View {
        Section(header: Text("Configuration")) {
            NavigationLink(destination: TaskCategoriesView()) {
                Label("Task categories", systemImage: "tray.full")
                    .foregroundColor(Color("Text"))
            }
        }
    }
    
    var helpSection: some View {
        Section(header: Text("Help")) {
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
    
    var pageFooter: some View {
        Section(header: Text("About")) {
            HStack {
                Image(systemName: "heart")
                VStack(alignment: .leading) {
                    Text("Made in Karlsruhe")
                    Text("Version \(Bundle.main.appVersion)")
                }
                .font(.footnote)
                .padding(.horizontal)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 3)
        }
    }
}

struct MorePageView_Previews: PreviewProvider {
    static var previews: some View {
        MorePageView()
            .preferredColorScheme(.dark)
    }
}
