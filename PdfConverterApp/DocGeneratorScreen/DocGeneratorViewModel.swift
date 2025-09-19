//
//  DocGeneratorViewModel.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 17.09.2025.
//

import SwiftUI
import PhotosUI
import PDFKit

final class DocGeneratorViewModel: NSObject, ObservableObject {

    @Published var selectedImages: [UIImage] = []
    @Published var generatedPDF: PDFDocument?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func removeImage(_ image: UIImage) {
        if let index = selectedImages.firstIndex(of: image) {
            selectedImages.remove(at: index)
        }
    }

    func generatePDF(completion: @escaping (Data?) -> Void) {
        guard !selectedImages.isEmpty else {
            errorMessage = "Нет изображений для создания PDF"
            completion(nil)
            return
        }

        let pdfDocument = PDFDocument()

        for (index, image) in selectedImages.enumerated() {
            if let pdfPage = PDFPage(image: image) {
                pdfDocument.insert(pdfPage, at: index)
            }
        }
        generatedPDF = pdfDocument
        completion(pdfDocument.dataRepresentation())
    }

    func clearSelection() {
        selectedImages.removeAll()
    }
}
