//
//  UIDeviceExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 06.09.22.
//

import SwiftUI

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
