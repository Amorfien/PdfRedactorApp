//
//  DocReaderViewModel.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 17.09.2025.
//

import SwiftUI
import PDFKit

//final class DocReaderViewModel: ObservableObject {
//
//    var pdfURL: URL
//
//    init(pdfURL: URL) {
//        self.pdfURL = pdfURL
//    }
//
//}

final class DocReaderViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var pdfDocument: PDFDocument?
    @Published var currentPageIndex: Int = 0
    @Published var totalPages: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var showDeleteConfirmation: Bool = false
    @Published var pageToDelete: Int?

    // MARK: - Properties
    private let pdfURL: URL
    private var temporaryPDFURL: URL?

    // MARK: - Init
    init(pdfURL: URL) {
        self.pdfURL = pdfURL
        loadPDFDocument()
    }

    // MARK: - Public Methods

    func loadPDFDocument() {
        isLoading = true
        errorMessage = nil

        do {
            let data = try Data(contentsOf: pdfURL)
            pdfDocument = PDFDocument(data: data)
            totalPages = pdfDocument?.pageCount ?? 0
            currentPageIndex = 0
        } catch {
            errorMessage = "Не удалось загрузить PDF: \(error.localizedDescription)"
            showError = true
        }

        isLoading = false
    }

    func goToNextPage() {
        guard let document = pdfDocument, currentPageIndex < document.pageCount - 1 else { return }
        currentPageIndex += 1
    }

    func goToPreviousPage() {
        guard currentPageIndex > 0 else { return }
        currentPageIndex -= 1
    }

    func goToPage(_ pageIndex: Int) {
        guard let document = pdfDocument, pageIndex >= 0, pageIndex < document.pageCount else { return }
        currentPageIndex = pageIndex
    }

    func requestDeletePage(at index: Int) {
        pageToDelete = index
        showDeleteConfirmation = true
    }

    func deletePage(at index: Int) {
        guard let document = pdfDocument, index >= 0, index < document.pageCount else { return }

        document.removePage(at: index)
        totalPages = document.pageCount

        // Обновляем текущую страницу если нужно
        if currentPageIndex >= totalPages {
            currentPageIndex = max(0, totalPages - 1)
        }

        // Сохраняем изменения во временный файл
        saveChanges()
    }

    func sharePDF() -> URL {
        // Возвращаем актуальный URL (оригинальный или временный с изменениями)
        return temporaryPDFURL ?? pdfURL
    }

    func saveToDocuments() {
        guard let document = pdfDocument else { return }

        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "edited_document_\(Date().timeIntervalSince1970).pdf"
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            if document.write(to: destinationURL) {
                print("Документ сохранен: \(destinationURL)")
                // Здесь можно добавить логику сохранения в CoreData
            }
        }
    }

    // MARK: - Private Methods

    private func saveChanges() {
        guard let document = pdfDocument else { return }

        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "temp_edited_\(Date().timeIntervalSince1970).pdf"
        let tempURL = tempDirectory.appendingPathComponent(fileName)

        if document.write(to: tempURL) {
            temporaryPDFURL = tempURL
        }
    }

    func getThumbnailForPage(at index: Int, size: CGSize = CGSize(width: 60, height: 80)) -> UIImage? {
        guard let document = pdfDocument, index >= 0, index < document.pageCount,
              let page = document.page(at: index) else {
            return nil
        }

        return page.thumbnail(of: size, for: .mediaBox)
    }

    var currentPage: PDFPage? {
        guard let document = pdfDocument, currentPageIndex >= 0, currentPageIndex < document.pageCount else {
            return nil
        }
        return document.page(at: currentPageIndex)
    }

    var pageIndices: [Int] {
        Array(0..<totalPages)
    }
}

// MARK: - PDF Document Extension for deletion
extension PDFDocument {
    func removePage(at index: Int) {
        guard index >= 0, index < pageCount else { return }

        // Создаем новый документ без удаленной страницы
        let newDocument = PDFDocument()

        for i in 0..<pageCount where i != index {
            if let page = page(at: i) {
                newDocument.insert(page, at: newDocument.pageCount)
            }
        }

        // Заменяем страницы в текущем документе
        for i in 0..<newDocument.pageCount {
            if let page = newDocument.page(at: i) {
                self.insert(page, at: i)
            }
        }

        // Удаляем лишние страницы
        while pageCount > newDocument.pageCount {
            removePage(at: pageCount - 1)
        }
    }
}
