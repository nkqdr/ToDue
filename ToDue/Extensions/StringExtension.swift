//
//  StringExtension.swift
//  ToDue
//
//  Created by Niklas Kuder on 02.03.23.
//

import Foundation

extension String {
    var isBlank: Bool {
        return allSatisfy({ $0.isWhitespace })
    }
}
