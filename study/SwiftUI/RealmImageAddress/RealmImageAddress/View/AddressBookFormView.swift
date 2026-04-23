//
//  AddressBookFormView.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import PhotosUI
import SwiftUI

struct AddressBookFormView: View {
    @ObservedObject var viewModel: AddressBookFormViewModel
    let onComplete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isShowingError = false

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    ContactAvatarView(imageData: viewModel.draft.imageData, size: 88)

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Text("갤러리에서 선택")
                            .font(.subheadline.weight(.semibold))
                    }
                }
                .padding(.vertical, 4)
            }

            Section("기본 정보") {
                TextField("이름", text: $viewModel.draft.name)
                TextField("전화번호", text: $viewModel.draft.phoneNumber)
                    .keyboardType(.phonePad)
                TextField("주소", text: $viewModel.draft.address, axis: .vertical)
                    .lineLimit(2...4)
                TextField("관계", text: $viewModel.draft.relationshipText)
            }

            Section {
                Button(viewModel.primaryButtonTitle) {
                    if viewModel.save() {
                        onComplete()
                        dismiss()
                    } else {
                        isShowingError = true
                    }
                }
                .frame(maxWidth: .infinity)
                .disabled(!viewModel.canSubmit)

                if viewModel.showsDeleteButton {
                    Button("삭제", role: .destructive) {
                        if viewModel.deleteContact() {
                            onComplete()
                            dismiss()
                        } else {
                            isShowingError = true
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .alert("오류", isPresented: $isShowingError, actions: {
            Button("확인") {
                viewModel.clearError()
            }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
        .task(id: selectedPhotoItem) {
            guard let selectedPhotoItem else { return }
            if let data = try? await selectedPhotoItem.loadTransferable(type: Data.self) {
                viewModel.draft.imageData = data
            }
        }
    }
}
