//
//  ContentView.swift
//  PhotoLibrary
//
//  Created by electrozone on 3/31/26.
//

import PhotosUI
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var isPhotoPickerPresented = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var isLoadingImage = false

    var body: some View {
        VStack(spacing: 24) {
            Button("Select an image") {
                isPhotoPickerPresented = true
            }
            .font(.title2.weight(.semibold))
            .buttonStyle(.plain)

            Group {
                if isLoadingImage {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: 520)
                } else if let selectedImage {
                    selectedImage
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 620)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
            .padding(.top, 40)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .photosPicker(
            isPresented: $isPhotoPickerPresented,
            selection: $selectedItem,
            matching: .images
        )
        .task(id: selectedItem) {
            await loadSelectedImage()
        }
    }

    @MainActor
    private func loadSelectedImage() async {
        guard let selectedItem else {
            selectedImage = nil
            isLoadingImage = false
            return
        }

        isLoadingImage = true
        defer { isLoadingImage = false }

        do {
            guard
                let imageData = try await selectedItem.loadTransferable(type: Data.self),
                let uiImage = UIImage(data: imageData)
            else {
                selectedImage = nil
                return
            }

            selectedImage = Image(uiImage: uiImage)
        } catch {
            selectedImage = nil
        }
    }
}

#Preview {
    ContentView()
}
