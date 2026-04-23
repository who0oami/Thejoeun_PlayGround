//
//  ContactAvatarView.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import SwiftUI

struct ContactAvatarView: View {
    let imageData: Data?
    let size: CGFloat

    var body: some View {
        Group {
            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .fill(Color(.systemGray5))
                    Image(systemName: "person.crop.square.fill")
                        .font(.system(size: size * 0.36))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
    }
}
