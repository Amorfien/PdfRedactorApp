//
//  DocGeneratorModel.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 19.09.2025.
//

import Foundation

struct DocGeneratorModel {
    let id: UUID?
    let name: String?
    let fileExtension: String?
    let creationDate: Date?
    let pdfData: Data?
    let thumbnail: Data?
    let fileSize: String?
}
