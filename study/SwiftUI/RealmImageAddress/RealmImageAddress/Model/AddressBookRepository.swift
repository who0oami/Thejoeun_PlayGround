//
//  AddressBookRepository.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import Foundation
import RealmSwift

enum AddressBookRepositoryError: LocalizedError {
    case invalidInput
    case contactNotFound

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "이름과 전화번호는 필수입니다."
        case .contactNotFound:
            return "해당 주소록 데이터를 찾을 수 없습니다."
        }
    }
}

final class AddressBookRepository {
    private let configuration: Realm.Configuration

    init(configuration: Realm.Configuration = .defaultConfiguration) {
        self.configuration = configuration
    }

    func fetchContacts(searchText: String = "") throws -> [AddressBookContact] {
        let realm = try realmInstance()
        var contacts = realm.objects(AddressBookContact.self)
            .sorted(by: [
                SortDescriptor(keyPath: "name", ascending: true),
                SortDescriptor(keyPath: "createdAt", ascending: false)
            ])

        let normalizedSearchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !normalizedSearchText.isEmpty {
            contacts = contacts.where {
                $0.name.contains(normalizedSearchText, options: .caseInsensitive) ||
                $0.phoneNumber.contains(normalizedSearchText, options: .caseInsensitive) ||
                $0.address.contains(normalizedSearchText, options: .caseInsensitive) ||
                $0.relationshipText.contains(normalizedSearchText, options: .caseInsensitive)
            }
        }

        return Array(contacts)
    }

    func fetchContact(id: ObjectId) throws -> AddressBookContact? {
        let realm = try realmInstance()
        return realm.object(ofType: AddressBookContact.self, forPrimaryKey: id)
    }

    @discardableResult
    func createContact(from draft: AddressBookContactDraft) throws -> ObjectId {
        guard draft.isValid else {
            throw AddressBookRepositoryError.invalidInput
        }

        let realm = try realmInstance()
        let contact = AddressBookContact(draft: draft)

        try realm.write {
            realm.add(contact)
        }

        return contact.id
    }

    func updateContact(id: ObjectId, with draft: AddressBookContactDraft) throws {
        guard draft.isValid else {
            throw AddressBookRepositoryError.invalidInput
        }

        let realm = try realmInstance()
        guard let contact = realm.object(ofType: AddressBookContact.self, forPrimaryKey: id) else {
            throw AddressBookRepositoryError.contactNotFound
        }

        try realm.write {
            contact.apply(draft: draft)
        }
    }

    func deleteContact(id: ObjectId) throws {
        let realm = try realmInstance()
        guard let contact = realm.object(ofType: AddressBookContact.self, forPrimaryKey: id) else {
            throw AddressBookRepositoryError.contactNotFound
        }

        try realm.write {
            realm.delete(contact)
        }
    }

    private func realmInstance() throws -> Realm {
        try Realm(configuration: configuration)
    }
}
