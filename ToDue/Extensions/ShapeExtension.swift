//
//  ShapeExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 23.09.22.
//

import Foundation
import SwiftUI

extension Shape {
    func versionAwareUltraThickFill() -> some View {
        if #available(iOS 15.0, *) {
            return self.fill(.ultraThickMaterial)
        } else {
            // Fallback on earlier versions
            return self.fill(Color("Accent1"))
        }
    }
}
