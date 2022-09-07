//
//  SettingsView.swift
//  ToDue
//
//  Created by Niklas Kuder on 26.08.22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    
    var body: some View {
        List {
            notificationSection
        }
        .navigationTitle("Settings")
        .background(Color("Background"))
    }
    
    var notificationSection: some View {
        Section(header: Text("Reminders"),
                footer: Text("To enable/disable notifications entirely, please go to your settings app.")) {
            Stepper("\(settingsManager.notificationDayDelta) days_until_due", value: $settingsManager.notificationDayDelta, in: 1...31)
            DatePicker("Remind me at", selection: $settingsManager.notificationReminderTime, displayedComponents: [.hourAndMinute])
        }
        .themedListRowBackground()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
