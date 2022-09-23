//
//  ViewExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.03.22.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
    
    @ViewBuilder
    public func currentDeviceNavigationViewStyle() -> some View {
        if UIDevice.isIPhone {
            self.navigationViewStyle(StackNavigationViewStyle())
        } else {
            self.navigationViewStyle(DefaultNavigationViewStyle())
        }
    }
    
    #if canImport(UIKit)
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    #endif
    
    func themedListRowBackground() -> some View {
        self.listRowBackground(Color("Accent2").opacity(0.3))
    }
    
    func hideScrollContentBackgroundIfNecessary() -> some View {
        if #available(iOS 16.0, *) {
            return self.scrollContentBackground(.hidden)
        } else {
            return self
        }
    }
    
    func versionAwareSearchable(text searchValue: Binding<String>) -> some View {
        if #available(iOS 15.0, *) {
            return self.searchable(text: searchValue)
        } else {
            return self
        }
    }
    
    func versionAwareBorderedButtonStyle() -> some View {
        if #available(iOS 15.0, *) {
            return self.buttonStyle(.bordered)
        } else {
            return self.buttonStyle(.automatic)
        }
    }
    
    func versionAwarePresentationDetents() -> some View {
        if #available(iOS 16.0, *) {
            return self.presentationDetents([.medium, .large])
        } else {
            return self
        }
    }
    
    func versionAwarePickerStyle(displayTitle: String) -> some View {
        if #available(iOS 16.0, *) {
            return self
        } else {
            return HStack {
                Text(displayTitle)
                Spacer()
                self.pickerStyle(.menu)
            }
        }
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
