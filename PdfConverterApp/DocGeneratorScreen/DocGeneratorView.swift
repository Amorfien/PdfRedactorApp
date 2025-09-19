//
//  DocumentGeneratorView.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import SwiftUI
import PhotosUI

struct DocGeneratorView: View {
    @ObservedObject private var viewModel: DocGeneratorViewModel
    @State private var showImagePicker = false
    @State private var showDocumentReader = false

    @State private var showLibraryPicker = false

    init(viewModel: DocGeneratorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if viewModel.selectedImages.isEmpty {
                EmptyStateView()


            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                        ForEach(viewModel.selectedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .cornerRadius(8)
                                .overlay(Button(action: {
                                    viewModel.removeImage(image)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }, alignment: .topTrailing)
                        }
                    }
                    .padding()
                }
            }

            if !viewModel.selectedImages.isEmpty {
                ActionButtonsView(viewModel: viewModel, showDocumentReader: $showDocumentReader)
            }
        }
        .navigationTitle("Создать PDF")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showLibraryPicker = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .imagePicker(
            isPresented: $showLibraryPicker,
            sourceType: .photoLibrary,
            onImageSelected: { image in
                viewModel.selectedImages.append(image)
            }
        )
        .sheet(isPresented: $showDocumentReader) {
            if let data = viewModel.generatedPDF?.dataRepresentation() {
                DocReaderView(viewModel: DocReaderViewModel(
                    pdfData: data,
                    fromGenerator: true,
                    onSaveTap: {
                    viewModel.savePDFToCoreData()
                }))
            }
        }
        .onDisappear {
            viewModel.clearSelection()
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("Выберите фотографии для создания PDF")
                .foregroundColor(.gray)
        }
        .frame(maxHeight: .infinity)
    }
}

struct ActionButtonsView: View {
    @ObservedObject var viewModel: DocGeneratorViewModel
    @Binding var showDocumentReader: Bool

    var body: some View {
        VStack(spacing: 15) {
            Button("Создать PDF") {
                viewModel.generatePDF { data in
                    if data != nil {
                        showDocumentReader = true
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        DocGeneratorView(viewModel: DocGeneratorViewModel())
    }
}
