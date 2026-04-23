//
//  AddressBookListViewModel.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import Combine
import Foundation
import RealmSwift

@MainActor
final class AddressBookListViewModel: ObservableObject {
    @Published var contacts: [AddressBookContact] = []
    @Published var searchText: String = ""
    @Published var errorMessage: String?
    @Published var isPresentingAddView: Bool = false

    private let repository: AddressBookRepository

    init(repository: AddressBookRepository) {
        self.repository = repository
    }

    convenience init() {
        self.init(repository: AddressBookRepository())
    }

    func loadContacts() {
        do {
            contacts = try repository.fetchContacts(searchText: searchText)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
