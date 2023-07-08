//
//  StatisticsView.swift
//  ToDue
//
//  Created by Niklas Kuder on 19.06.23.
//

import SwiftUI

@available(iOS 15.0, *)
struct StatisticsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    GroupBox("Upcoming tasks") {
                       
                    }
                    .groupBoxStyle(CustomGroupBox())
                    GroupBox("Tasks completed this month") {
                       
                    }
                    .groupBoxStyle(CustomGroupBox())
                    GroupBox("Completed tasks per category") {
                        
                    }
                    .groupBoxStyle(CustomGroupBox())
                }
                .padding()
            }
            .background(Color("Background").ignoresSafeArea())
            .navigationTitle("Statistics")
        }
        .currentDeviceNavigationViewStyle()
    }
}

fileprivate struct CustomGroupBox: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            HStack {
                configuration.label
                    .font(.headline)
                Spacer()
            }
            configuration.content
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill(Color("Accent2").opacity(0.3)))
    }
}

@available(iOS 15.0, *)
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
