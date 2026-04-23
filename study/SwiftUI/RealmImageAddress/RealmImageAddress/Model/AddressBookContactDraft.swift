//
//  AddressBookContactDraft.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import Foundation

struct AddressBookContactDraft: Equatable, Sendable {
    var name: String = ""
    var phoneNumber: String = ""
    var address: String = ""
    var relationshipText: String = ""
    var imageData: Data?

    init(
        name: String = "",
        phoneNumber: String = "",
        address: String = "",
        relationshipText: String = "",
        imageData: Data? = nil
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.address = address
        self.relationshipText = relationshipText
        self.imageData = imageData
    }

    init(contact: AddressBookContact) {
        self.init(
            name: contact.name,
            phoneNumber: contact.phoneNumber,
            address: contact.address,
            relationshipText: contact.relationshipText,
            imageData: contact.imageData
        )
    }

    var isValid: Bool {
        !trimmedName.isEmpty && !trimmedPhoneNumber.isEmpty
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var trimmedPhoneNumber: String {
        phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
