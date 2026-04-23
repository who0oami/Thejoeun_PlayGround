//
//  TextFieldRowView.swift
//  Computer_codex
//
//  Created by Codex.
//

import SwiftUI

struct TextFieldRowView: View {
    let title: String
    let displayText: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .frame(minWidth: 80, alignment: .leading)

            TextField(
                placeholder,
                text: $text,
                prompt: Text(displayText.isEmpty ? placeholder : displayText)
                    .foregroundStyle(displayText.isEmpty ? .secondary : .primary)
            )
            .textFieldStyle(.roundedBorder)
            .frame(width: 200)
        }
    }
}
