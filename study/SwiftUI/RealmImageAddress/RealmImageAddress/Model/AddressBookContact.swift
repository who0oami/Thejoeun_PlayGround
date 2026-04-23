//
//  AddressBookContact.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import Foundation
import RealmSwift

final class AddressBookContact: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var name: String = ""
    @Persisted var phoneNumber: String = ""
    @Persisted var address: String = ""
    @Persisted var relationshipText: String = ""
    @Persisted var imageData: Data?
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()

    convenience init(draft: AddressBookContactDraft) {
        self.init()
        apply(draft: draft)
    }

    func apply(draft: AddressBookContactDraft) {
        name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        phoneNumber = draft.phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        address = draft.address.trimmingCharacters(in: .whitespacesAndNewlines)
        relationshipText = draft.relationshipText.trimmingCharacters(in: .whitespacesAndNewlines)
        imageData = draft.imageData
        updatedAt = Date()
    }
}
