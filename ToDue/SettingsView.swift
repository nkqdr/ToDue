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
    enum AppTheme: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: Self { self }
    }

    @State private var selectedFlavor: AppTheme = .system
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Group {
                        Section("General") {
                            NavigationLink("Something") {
                                
                            }
                            NavigationLink("Something else") {
                                
                            }
                        }
                        
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
                        Section("Help") {
                            NavigationLink("Some help") {
                                
                            }
                        }
                    }
                    .listRowBackground(Color("Accent2").opacity(0.3))
                    Group {
                        Divider()
                        Text("Made in Karlsruhe with ♡")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(.none)
                    .listRowBackground(Color("Accent2").opacity(0))
                }
                .background(Color("Background"))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
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
