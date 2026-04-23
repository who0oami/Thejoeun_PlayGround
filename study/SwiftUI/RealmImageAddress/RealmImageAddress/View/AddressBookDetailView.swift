//
//  AddressBookDetailView.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import RealmSwift
import SwiftUI

struct AddressBookDetailView: View {
    let contactID: ObjectId
    let onComplete: () -> Void

    var body: some View {
        AddressBookFormView(
            viewModel: AddressBookFormViewModel(mode: .edit(contactID)),
            onComplete: onComplete
        )
    }
}
