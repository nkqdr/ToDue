//
//  FAQView.swift
//  ToDue
//
//  Created by Niklas Kuder on 26.08.22.
//

import SwiftUI

struct FAQView: View {
    var body: some View {
        List {
            Section("") {
                DisclosureGroup("Wie kann ich eine Aufgabe löschen?") {
                    Text("Wenn man eine Aufgabe kurz gedrückt hält, bekommt man mehrere Funktionen angezeigt. Dort kann man sie unter Anderem auch löschen.")
                }
                DisclosureGroup("Ist die Erde flach?") {
                    Text("Nein!")
                }
                DisclosureGroup("Ist die Erde flach?") {
                    Text("Nein!")
                }
            }
            .listRowBackground(Color("Accent2").opacity(0.3))
        }
        .navigationTitle("FAQ")
        .background(Color("Background"))
    }
}

struct FAQView_Previews: PreviewProvider {
    static var previews: some View {
        FAQView()
    }
}
