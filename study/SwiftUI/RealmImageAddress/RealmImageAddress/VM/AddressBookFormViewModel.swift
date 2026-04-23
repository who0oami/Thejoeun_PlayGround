//
//  AddressBookFormViewModel.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import Combine
import Foundation
import RealmSwift

enum AddressBookFormMode {
    case create
    case edit(ObjectId)

    var navigationTitle: String {
        switch self {
        case .create:
            return "주소록 등록"
        case .edit:
            return "연락처 수정"
        }
    }

    var primaryButtonTitle: String {
        switch self {
        case .create:
            return "등록"
        case .edit:
            return "수정"
        }
    }

    var showsDeleteButton: Bool {
        if case .edit = self {
            return true
        }
        return false
    }
}

@MainActor
final class AddressBookFormViewModel: ObservableObject {
    @Published var draft: AddressBookContactDraft
    @Published var errorMessage: String?

    let mode: AddressBookFormMode
    private let repository: AddressBookRepository

    init(
        mode: AddressBookFormMode,
        repository: AddressBookRepository
    ) {
        self.mode = mode
        self.repository = repository

        switch mode {
        case .create:
            draft = AddressBookContactDraft()
        case .edit(let id):
            let contact = try? repository.fetchContact(id: id)
            if let contact {
                draft = AddressBookContactDraft(contact: contact)
            } else {
                draft = AddressBookContactDraft()
                errorMessage = AddressBookRepositoryError.contactNotFound.localizedDescription
            }
        }
    }

    convenience init(mode: AddressBookFormMode) {
        self.init(mode: mode, repository: AddressBookRepository())
    }

    var navigationTitle: String {
        mode.navigationTitle
    }

    var primaryButtonTitle: String {
        mode.primaryButtonTitle
    }

    var showsDeleteButton: Bool {
        mode.showsDeleteButton
    }

    var canSubmit: Bool {
        draft.isValid
    }

    func save() -> Bool {
        do {
            switch mode {
            case .create:
                try repository.createContact(from: draft)
            case .edit(let id):
                try repository.updateContact(id: id, with: draft)
            }

            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteContact() -> Bool {
        guard case .edit(let id) = mode else {
            return false
        }

        do {
            try repository.deleteContact(id: id)
            errorMessage = nil
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
