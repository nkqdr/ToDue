//
//  SettingsView.swift
//  ToDue
//
//  Created by Niklas Kuder on 26.08.22.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @AppStorage("notificationDayDelta") private var notificationDayDelta: Int = 1
    @AppStorage("notificationReminderTime") private var notificationReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0, second: 0))!
    
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
            Stepper("\(notificationDayDelta) days_until_due", value: $notificationDayDelta, in: 1...31)
                .onChange(of: notificationDayDelta) { _ in
                    settingsManager.refreshNotifications()
                }
            DatePicker("Remind me at", selection: $notificationReminderTime, displayedComponents: [.hourAndMinute])
                .onChange(of: notificationReminderTime) { _ in
                    settingsManager.refreshNotifications()
                }
        }
        .themedListRowBackground()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
