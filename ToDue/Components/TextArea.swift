//
//  TextArea.swift
//  ToDue
//
//  Created by Niklas Kuder on 02.03.23.
//

import SwiftUI

struct TextArea: View {
    private let placeholder: LocalizedStringKey
    @Binding var text: String
    
    init(_ placeholder: LocalizedStringKey, text: Binding<String>) {
        self.placeholder = placeholder
        self._text = text
    }
    
    var body: some View {
        TextEditor(text: $text)
            .background(
                VStack {
                    HStack(alignment: .top) {
                        text.isBlank ? Text(placeholder) : Text("")
                        Spacer()
                    }
                    Spacer()
                }
                .foregroundColor(Color.primary.opacity(0.25))
                .padding(.vertical, 8)
                .padding(.horizontal, 3)
            )
    }
}
