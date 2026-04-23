//
//  ClearButtonView.swift
//  Computer_codex
//
//  Created by Codex.
//

import SwiftUI

struct ClearButtonView: View {
    let action: () -> Void

    var body: some View {
        Button("Clear", action: action)
            .padding()
            .frame(width: 80)
            .foregroundStyle(.red)
            .border(.red, width: 1)
    }
}
