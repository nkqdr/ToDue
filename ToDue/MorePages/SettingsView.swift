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
    @State private var shouldUseIcloudSync: Bool = NSUbiquitousKeyValueStore.default.bool(forKey: "use_icloud_sync")
    
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
    
    private var iCloudListView: some View {
        List {
            VStack(alignment: .center) {
                Image(systemName: "icloud")
                    .font(.system(size: 60))
                Text("Synchronize app data via iCloud.")
                    .padding(.vertical)
                    .multilineTextAlignment(.center)
                Text("Make sure to sign in to your iCloud account. \nOn the Home screen, launch Settings, tap iCloud, and enter your Apple ID. Turn iCloud Drive on.")
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.secondary.opacity(0.8))
            .listRowBackground(Color("Background"))
            .padding(.top, 30)
            Section {
                Toggle("iCloud Sync", isOn: $shouldUseIcloudSync)
                    .themedListRowBackground()
                    .onChange(of: shouldUseIcloudSync) { newValue in
                        settingsManager.handleIcloudSyncToggle(newValue)
                    }
            }
        }
        .groupListStyleIfNecessary()
        .navigationTitle("iCloud Backup")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("Background").ignoresSafeArea())
        .hideScrollContentBackgroundIfNecessary()
    }
    
    private var icloudSection: some View {
        Section(header: Text("sync"), footer: Text("Decide whether or not you want to synchronize your data between all of your devices.").listRowBackground(Color("Background"))) {
            NavigationLink("iCloud Backup") {
                iCloudListView
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
