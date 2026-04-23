//
//  OKButtonView.swift
//  Computer_codex
//
//  Created by Codex.
//

import SwiftUI

struct OKButtonView: View {
    let action: () -> Void

    var body: some View {
        Button("OK", action: action)
            .padding()
            .frame(width: 80)
            .background(.blue)
            .foregroundStyle(.white)
            .clipShape(.buttonBorder)
    }
}
