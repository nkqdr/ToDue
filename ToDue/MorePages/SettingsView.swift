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
    @AppStorage("shouldUseReminders") private var shouldUseReminders = true
    @AppStorage("shouldUseIcloudSync") private var shouldUseIcloudSync = true
    
    var body: some View {
        List {
            remindersSection
            icloudSection
        }
        .groupListStyleIfNecessary()
        .navigationTitle("Settings")
        .background(Color("Background").ignoresSafeArea())
        .hideScrollContentBackgroundIfNecessary()
    }
    
    private var icloudSection: some View {
        Section(header: Text("sync"), footer: Text("Decide whether or not you want to synchronize your data between all of your devices.").listRowBackground(Color("Background"))) {
            Toggle("iCloud Sync", isOn: $shouldUseIcloudSync)
                .onChange(of: shouldUseIcloudSync) { newValue in
                    print(newValue)
                }
        }
        .themedListRowBackground()
    }
    
    private var remindersSection: some View {
        Section(header: Text("Reminders"),
                footer: Text("reminder_settings_footer").listRowBackground(Color("Background"))) {
            Toggle("Enable reminders", isOn: $shouldUseReminders)
                .onChange(of: shouldUseReminders) { newValue in
                    if newValue {
                        settingsManager.setAllReminderNotifications()
                    } else {
                        settingsManager.removeAllReminderNotifications()
                    }
                }
            Group {
                Stepper("\(notificationDayDelta) days_until_due", value: $notificationDayDelta, in: 1...31)
                    .onChange(of: notificationDayDelta) { _ in
                        settingsManager.refreshNotifications()
                    }
                DatePicker("Remind me at", selection: $notificationReminderTime, displayedComponents: [.hourAndMinute])
                    .onChange(of: notificationReminderTime) { _ in
                        settingsManager.refreshNotifications()
                    }
            }
            .foregroundColor(!shouldUseReminders ? .secondary : nil)
            .disabled(!shouldUseReminders)
        }
        .themedListRowBackground()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
