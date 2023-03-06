//
//  ToastViewModel.swift
//  ToDue
//
//  Created by Niklas Kuder on 01.03.23.
//

import Foundation
import AlertToast
import SwiftUI

class ToastViewModel: ObservableObject {
    public static let shared = ToastViewModel()
    
    @Published var show: Bool = false
    @Published var alertToast: AlertToast {
        didSet {
            show.toggle()
        }
    }
    
    private init() {
        self.show = false
        self.alertToast = AlertToast(
            displayMode: .hud,
            type: .complete(.green),
            title: "Yeet"
        )
    }
    
    // MARK: - Intents
    
    func showSuccess(title: String? = "Success", message: String) {
        alertToast = AlertToast(
            displayMode: .hud,
            type: .complete(.green),
            title: title,
            subTitle: message,
            style: .style(backgroundColor: Color("AccentLight"), titleColor: Color("Text"), subTitleColor: .secondary)
        )
    }
}
