//
//  ContentView.swift
//  SQLiteImageAddress
//
//  Created by electrozone on 3/31/26.
//

import PhotosUI
import SwiftUI

struct ContentView: View {
    @StateObject private var addressDB = AddressDB()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(addressDB.addressList) { address in
                    NavigationLink {
                        AddressFormView(addressDB: addressDB, mode: .edit(address))
                    } label: {
                        AddressRowView(address: address)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("주소록")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AddressFormView(addressDB: addressDB, mode: .add)
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .onAppear {
                addressDB.loadAddresses()
            }
        }
    }
}

private struct AddressRowView: View {
    let address: Address
    
    var body: some View {
        HStack(spacing: 16) {
            Image(uiImage: address.image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(address.name)
                    .font(.headline)
                Text(address.phone)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 6)
    }
}

private struct AddressFormView: View {
    enum Mode {
        case add
        case edit(Address)
        
        var navigationTitle: String {
            switch self {
            case .add:
                return "주소록 입력"
            case .edit:
                return "주소록 수정 및 삭제"
            }
        }
    }
    
    @ObservedObject var addressDB: AddressDB
    let mode: Mode
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var relation = ""
    @State private var selectedImage: UIImage = UIImage(systemName: "person.crop.square") ?? UIImage()
    @State private var photoItem: PhotosPickerItem?
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var shouldDismissAfterAlert = false
    
    var body: some View {
        Form {
            Section {
                LabeledInputRow(title: "이름 :", text: $name)
                LabeledInputRow(title: "전화번호 :", text: $phone, keyboardType: .phonePad)
                LabeledInputRow(title: "주소 :", text: $address)
                LabeledInputRow(title: "관계 :", text: $relation)
            }
            
            Section {
                VStack(spacing: 16) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Text("Select an image")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
            
            Section {
                switch mode {
                case .add:
                    Button("등록") {
                        insertAddress()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                case .edit(let currentAddress):
                    HStack(spacing: 16) {
                        Button("수정") {
                            updateAddress(id: currentAddress.id)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        
                        Button("삭제") {
                            deleteAddress(id: currentAddress.id)
                        }
                        .frame(maxWidth: .infinity)
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                    }
                }
            }
            .listRowBackground(Color.clear)
        }
        .navigationTitle(mode.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: photoItem) {
            await loadSelectedPhoto()
        }
        .onAppear {
            configureForm()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("네, 알겠습니다.") {
                if shouldDismissAfterAlert {
                    dismiss()
                }
            }
        }
    }
    
    private func configureForm() {
        guard case let .edit(currentAddress) = mode else { return }
        
        name = currentAddress.name
        phone = currentAddress.phone
        address = currentAddress.address
        relation = currentAddress.relation
        selectedImage = currentAddress.image
    }
    
    private func insertAddress() {
        let result = addressDB.insertDB(
            name: name,
            phone: phone,
            address: address,
            relation: relation,
            image: selectedImage
        )
        
        if result {
            alertTitle = "입력 되었습니다."
            shouldDismissAfterAlert = true
            showAlert = true
        }
    }
    
    private func updateAddress(id: Int) {
        let result = addressDB.updateDB(
            id: id,
            name: name,
            phone: phone,
            address: address,
            relation: relation,
            image: selectedImage
        )
        
        if result {
            alertTitle = "수정 되었습니다."
            shouldDismissAfterAlert = true
            showAlert = true
        }
    }
    
    private func deleteAddress(id: Int) {
        let result = addressDB.deleteDB(id: id)
        
        if result {
            alertTitle = "삭제 되었습니다."
            shouldDismissAfterAlert = true
            showAlert = true
        }
    }
    
    private func loadSelectedPhoto() async {
        guard let photoItem else { return }
        
        do {
            if let data = try await photoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
            }
        } catch {
            print("image load error: \(error.localizedDescription)")
        }
    }
}

private struct LabeledInputRow: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .frame(width: 90, alignment: .leading)
            
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .textFieldStyle(.roundedBorder)
        }
    }
}

#Preview {
    ContentView()
}
