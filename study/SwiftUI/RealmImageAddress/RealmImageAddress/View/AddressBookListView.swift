//
//  AddressBookListView.swift
//  RealmImageAddress
//
//  Created by Codex.
//

import RealmSwift
import SwiftUI

struct AddressBookListView: View {
    @StateObject private var viewModel = AddressBookListViewModel()
    @State private var isShowingError = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.contacts.isEmpty {
                    ContentUnavailableView(
                        "연락처가 없습니다",
                        systemImage: "person.text.rectangle",
                        description: Text("오른쪽 위 플러스 버튼으로 주소록을 등록하세요.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.contacts, id: \.id) { contact in
                                NavigationLink(value: contact.id) {
                                    AddressBookContactCardView(contact: contact)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("주소록")
            .searchable(text: $viewModel.searchText, prompt: "이름, 전화번호, 주소, 관계 검색")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isPresentingAddView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: ObjectId.self) { contactID in
                AddressBookDetailView(contactID: contactID) {
                    viewModel.loadContacts()
                }
            }
            .sheet(isPresented: $viewModel.isPresentingAddView, onDismiss: {
                viewModel.loadContacts()
            }) {
                NavigationStack {
                    AddressBookFormView(
                        viewModel: AddressBookFormViewModel(mode: .create),
                        onComplete: {
                            viewModel.loadContacts()
                        }
                    )
                }
            }
            .onAppear {
                viewModel.loadContacts()
            }
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.loadContacts()
            }
            .onChange(of: viewModel.errorMessage) { _, newValue in
                isShowingError = newValue != nil
            }
            .alert("오류", isPresented: $isShowingError, actions: {
                Button("확인") {
                    viewModel.clearError()
                }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
        }
    }
}
