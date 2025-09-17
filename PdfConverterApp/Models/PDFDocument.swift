//
//  PDFDocument.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import Foundation
import CoreData

@objc(PDFDocument)
public class PDFDocument: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var fileExtension: String
    @NSManaged public var creationDate: Date
    @NSManaged public var thumbnail: Data?
    @NSManaged public var fileURL: URL
}

extension PDFDocument {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<PDFDocument> {
        return NSFetchRequest<PDFDocument>(entityName: "PDFDocument")
    }
}
