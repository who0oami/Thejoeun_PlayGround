//
//  AddressBookContactCardView.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import SwiftUI

struct AddressBookContactCardView: View {
    let contact: AddressBookContact

    var body: some View {
        HStack(spacing: 16) {
            ContactAvatarView(imageData: contact.imageData, size: 72)

            VStack(alignment: .leading, spacing: 8) {
                Text(contact.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(contact.phoneNumber)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.15), lineWidth: 1)
        )
    }
}
