//
//  DocReaderViewModel.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 17.09.2025.
//

import SwiftUI
import PDFKit

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

    var onSaveTap: (() -> Void)?

    // MARK: - Properties
    let pdfData: Data
    let fromGenerator: Bool

    // MARK: - Init

    init(pdfData: Data, fromGenerator: Bool = false, onSaveTap: (() -> Void)? = nil) {
        self.pdfData = pdfData
        self.fromGenerator = fromGenerator
        self.onSaveTap = onSaveTap
        loadPDFDocument()
    }

    // MARK: - Public Methods

    func loadPDFDocument() {
        isLoading = true
        errorMessage = nil

        guard let pdf = PDFDocument(data: pdfData) else { return }
        pdfDocument = pdf
        totalPages = pdf.pageCount
        currentPageIndex = 0

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

        self.pdfDocument = document

        // Сохраняем изменения во временный файл
//        saveChanges()
    }

    func sharePDF() -> URL? {
        guard let data = pdfDocument?.dataRepresentation() else { return nil}
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("document.pdf")

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Ошибка сохранения временного файла: \(error)")
            return fileURL
        }
    }

    func saveToDb() {
        onSaveTap?()
    }

    // MARK: - Private Methods

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
