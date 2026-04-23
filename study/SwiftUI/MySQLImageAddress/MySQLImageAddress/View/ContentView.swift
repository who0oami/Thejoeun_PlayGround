//
//  ContentView.swift
//  SQLiteImageAddress
//
//  Created by electrozone on 3/31/26.
//

import Photos
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
            .task {
                await addressDB.loadAddresses()
            }
            .alert("오류", isPresented: errorAlertBinding) {
                Button("확인") {
                    addressDB.errorMessage = ""
                }
            } message: {
                Text(addressDB.errorMessage)
            }
        }
    }
    
    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { addressDB.errorMessage.isEmpty == false },
            set: { isPresented in
                if isPresented == false {
                    addressDB.errorMessage = ""
                }
            }
        )
    }
}

private struct AddressRowView: View {
    let address: Address
    
    var body: some View {
        HStack(spacing: 16) {
            AddressRemoteImageView(imageName: address.image, width: 60, height: 60)
            
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
    @State private var image = ""
    @State private var selectedImage: UIImage?
    @State private var photoItem: PhotosPickerItem?
    @State private var selectedFileName: String?
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
                        Text("이미지 선택")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    previewContent
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
                            updateAddress(original: currentAddress)
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
    
    @ViewBuilder
    private var previewContent: some View {
        if let selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .frame(height: 180)
        } else {
            AddressRemoteImageView(imageName: image, width: 180, height: 180)
        }
    }
    
    private func configureForm() {
        guard case let .edit(currentAddress) = mode else { return }
        
        name = currentAddress.name
        phone = currentAddress.phone
        address = currentAddress.address
        relation = currentAddress.relation
        image = currentAddress.image
        selectedImage = nil
        selectedFileName = nil
    }
    
    private func insertAddress() {
        Task {
            let finalImageName: String
            
            do {
                if let selectedImage {
                    finalImageName = try await addressDB.uploadImage(selectedImage, fileName: selectedFileName)
                } else {
                    finalImageName = ImageUtil.getImageName(image)
                }
            } catch {
                addressDB.errorMessage = error.localizedDescription
                return
            }
            
            let result = await addressDB.insertDB(
                name: name,
                phone: phone,
                address: address,
                relation: relation,
                image: finalImageName
            )
            
            if result {
                alertTitle = "입력 되었습니다."
                shouldDismissAfterAlert = true
                showAlert = true
            }
        }
    }
    
    private func updateAddress(original: Address) {
        Task {
            let finalImageName: String
            
            do {
                if let selectedImage {
                    finalImageName = try await addressDB.uploadImage(selectedImage, fileName: selectedFileName)
                } else {
                    finalImageName = original.image
                }
            } catch {
                addressDB.errorMessage = error.localizedDescription
                return
            }
            
            let result = await addressDB.updateDB(
                original: original,
                name: name,
                phone: phone,
                address: address,
                relation: relation,
                image: finalImageName
            )
            
            if result {
                alertTitle = "수정 되었습니다."
                shouldDismissAfterAlert = true
                showAlert = true
            }
        }
    }
    
    private func deleteAddress(id: Int) {
        Task {
            let result = await addressDB.deleteDB(id: id)
            
            if result {
                alertTitle = "삭제 되었습니다."
                shouldDismissAfterAlert = true
                showAlert = true
            }
        }
    }
    
    private func loadSelectedPhoto() async {
        guard let photoItem else { return }
        
        do {
            if let data = try await photoItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                selectedFileName = await preferredFileName(for: photoItem)
            }
        } catch {
            addressDB.errorMessage = "이미지를 불러오지 못했습니다. \(error.localizedDescription)"
        }
    }
    
    private func preferredFileName(for item: PhotosPickerItem) async -> String? {
        guard let itemIdentifier = item.itemIdentifier else { return nil }
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [itemIdentifier], options: nil)
        guard let asset = assets.firstObject else { return nil }
        let resources = PHAssetResource.assetResources(for: asset)
        return resources.first?.originalFilename
    }
}

private struct AddressRemoteImageView: View {
    let imageName: String
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        if let imageURL = ImageUtil.imageURL(for: imageName) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    Image("default")
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Image("default")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipShape(RoundedRectangle(cornerRadius: 12))
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
