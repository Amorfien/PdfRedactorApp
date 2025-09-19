//
//  DocumentService.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 19.09.2025.
//

import Foundation
import UIKit
import PDFKit

struct DocumentService {

//    static let shared = DocumentService()
//
//    private init() {}

    static func makeThumbnail(from pdfData: Data?) -> Data? {
        guard let pdfData else { return nil }
        var thumbnailData: Data? = nil
        if let pdfDocument = PDFDocument(data: pdfData),
           let firstPage = pdfDocument.page(at: 0) {
            let thumbnailSize = CGSize(width: 100, height: 150)
            let thumbnail = firstPage.thumbnail(of: thumbnailSize, for: .cropBox)
            thumbnailData = thumbnail.pngData()
        }
        return thumbnailData
    }

    static func makeFileSizeStr(from pdfData: Data?) -> String {
        guard let pdfData else { return "Н/Д" }
        let byteCount = Int64(pdfData.count)
        
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.isAdaptive = true
        
        return formatter.string(fromByteCount: byteCount)
    }
}
