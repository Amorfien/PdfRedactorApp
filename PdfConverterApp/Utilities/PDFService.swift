//
//  PDFService.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 19.09.2025.
//

//import UIKit
//import PDFKit
//
//class PDFService {
//    static let shared = PDFService()
//
//    func createPDF(from images: [UIImage], completion: @escaping (URL?) -> Void) {
//        let pdfDocument = PDFDocument()
//
//        for (index, image) in images.enumerated() {
//            if let pdfPage = PDFPage(image: image) {
//                pdfDocument.insert(pdfPage, at: index)
//            }
//        }
//
//        let tempDirectory = FileManager.default.temporaryDirectory
//        let fileName = "document_\(Date().timeIntervalSince1970).pdf"
//        let fileURL = tempDirectory.appendingPathComponent(fileName)
//
//        if pdfDocument.write(to: fileURL) {
//            completion(fileURL)
//        } else {
//            completion(nil)
//        }
//    }

//    func generateThumbnail(for pdfURL: URL, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
//        guard let document = PDFDocument(url: pdfURL),
//              let page = document.page(at: 0) else { return nil }
//
//        let pageSize = page.bounds(for: .mediaBox)
//        let scale = min(size.width / pageSize.width, size.height / pageSize.height)
//        let scaledSize = CGSize(width: pageSize.width * scale, height: pageSize.height * scale)
//
//        return page.thumbnail(of: scaledSize, for: .mediaBox)
//    }
//}
