//
//  DocumentGeneratorView.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import SwiftUI
import PhotosUI

// FIXME: PhotosPickerItem vs 15.0
@available(iOS 16.0, *)
struct DocGeneratorView: View {
    @ObservedObject private var viewModel: DocGeneratorViewModel
    @State private var showImagePicker = false
    @State private var showDocumentReader = false
    @State private var navigateToStorage = false

    init(viewModel: DocGeneratorViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            if viewModel.selectedImages.isEmpty {
                EmptyStateView()
                actionButton
                NavigationLink(
                    destination: SavedDocsView(viewModel: SavedDocsViewModel()),
                    isActive: $navigateToStorage,
                    label: { EmptyView() }
                )
                .hidden()
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                PhotosPicker(selection: $viewModel.selectedItems,
                           matching: .images,
                           photoLibrary: .shared()) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showDocumentReader) {
            if let pdfURL = viewModel.generatedPDFURL {
                DocReaderView(pdfURL: pdfURL, viewModel: DocReaderViewModel(pdfURL: pdfURL))
            }
        }
    }

    private var actionButton: some View {
        Button(action: {
//            viewModel.nextButtonDidTap()
            navigateToStorage = true
        }) {
            Text("Посмотреть сохраненные")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
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

@available(iOS 16.0, *)
struct ActionButtonsView: View {
    @ObservedObject var viewModel: DocGeneratorViewModel
    @Binding var showDocumentReader: Bool

    var body: some View {
        VStack(spacing: 15) {
            Button("Создать PDF") {
                viewModel.generatePDF { url in
                    if url != nil {
                        showDocumentReader = true
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle())

            Button("Сохранить") {
                viewModel.savePDF()
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding()
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        DocGeneratorView(viewModel: DocGeneratorViewModel(context: CoreDataManager.shared.container.viewContext))
    } else {
        // Fallback on earlier versions
    }
}
