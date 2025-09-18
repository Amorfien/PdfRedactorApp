////
////  SavedDocsView.swift
////  PdfConverterApp
////
////  Created by Pavel Grigorev on 17.09.2025.
////
//
//import SwiftUI
//import CoreData
//
//struct SavedDocsView: View {
//    @ObservedObject private var viewModel: SavedDocsViewModel
//    @State private var showShareSheet = false
//    @State private var documentToShare: DocumentEntity?
//
//    init(viewModel: SavedDocsViewModel) {
//        self.viewModel = viewModel
//    }
//
//    var body: some View {
//        ZStack {
//            if viewModel.isLoading && viewModel.documents.isEmpty {
//                ProgressView("Загрузка документов...")
//            } else if viewModel.documents.isEmpty {
//                emptyStateView
//            } else {
//                documentsListView
//            }
//
//            if viewModel.isLoading {
//                LoadingOverlay()
//            }
//        }
//        .navigationTitle("Мои документы")
//        .navigationBarTitleDisplayMode(.large)
////        .toolbar {
////            if viewModel.showMergeSelection {
////                ToolbarItem(placement: .navigationBarLeading) {
////                    Button("Отмена") {
////                        viewModel.cancelMerge()
////                    }
////                }
////                ToolbarItem(placement: .navigationBarTrailing) {
////                    Button("Объединить") {
//////                        viewModel.completeMerge()
////                    }
////                    .disabled(viewModel.documentsToMerge.count < 2)
////                }
////            }
////        }
//        .alert("Ошибка", isPresented: $viewModel.showError) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
//        }
//        .sheet(isPresented: $showShareSheet) {
//            if let document = documentToShare {
//                ShareSheet(activityItems: [viewModel.shareDocument(document)])
//            }
//        }
//        .sheet(isPresented: $viewModel.showDocumentReader) {
////            if let document = viewModel.selectedDocument, let url = document.fileURL {
////                DocReaderView(pdfURL: document.fileURL)
////                DocReaderView(viewModel: DocReaderViewModel(pdfURL: url))
//            }
//        }
//    }
//
//    private var documentsListView: some View {
//        List {
//            ForEach(viewModel.documents, id: \.id) { document in
//                DocumentCell(
//                    document: document,
//                    isSelected: viewModel.documentsToMerge.contains(where: { $0.id == document.id }),
//                    isMergeMode: viewModel.showMergeSelection
//                )
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    if viewModel.showMergeSelection {
//                        if viewModel.documentsToMerge.contains(where: { $0.id == document.id }) {
//                            viewModel.removeDocumentFromMerge(document)
//                        } else {
//                            viewModel.addDocumentToMerge(document)
//                        }
//                    } else {
//                        viewModel.selectedDocument = document
//                        viewModel.showDocumentReader = true
//                    }
//                }
//                .contextMenu {
//                    if !viewModel.showMergeSelection {
//                        Button {
//                            documentToShare = document
//                            showShareSheet = true
//                        } label: {
//                            Label("Поделиться", systemImage: "square.and.arrow.up")
//                        }
//
//                        Button {
//                            viewModel.startMergeProcess(with: document)
//                        } label: {
//                            Label("Объединить", systemImage: "doc.on.doc")
//                        }
//
//                        Button(role: .destructive) {
//                            viewModel.deleteDocument(document)
//                        } label: {
//                            Label("Удалить", systemImage: "trash")
//                        }
//                    }
//                }
//            }
//        }
//        .listStyle(PlainListStyle())
//    }
//
//    private var emptyStateView: some View {
//        VStack(spacing: 20) {
//            Image(systemName: "doc.text.magnifyingglass")
//                .font(.system(size: 60))
//                .foregroundColor(.gray)
//
//            Text("Нет сохраненных документов")
//                .font(.headline)
//                .foregroundColor(.primary)
//
//            Text("Создайте свой первый PDF документ")
//                .font(.subheadline)
//                .foregroundColor(.secondary)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//    }
//}
//
//// MARK: - DocumentCell
//struct DocumentCell: View {
//    let document: DocumentEntity
//    let isSelected: Bool
//    let isMergeMode: Bool
//
//    var body: some View {
//        HStack(spacing: 16) {
//            // Thumbnail
//            if let thumbnailData = document.thumbnail,
//               let uiImage = UIImage(data: thumbnailData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 60, height: 80)
//                    .cornerRadius(8)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 8)
//                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//                    )
//            } else {
//                Rectangle()
//                    .fill(Color.gray.opacity(0.2))
//                    .frame(width: 60, height: 80)
//                    .cornerRadius(8)
//                    .overlay(
//                        Image(systemName: "doc")
//                            .foregroundColor(.gray)
//                    )
//            }
//
//            // Document Info
//            VStack(alignment: .leading, spacing: 4) {
//                Text(document.name ?? "Без названия")
//                    .font(.headline)
//                    .lineLimit(1)
//
//                Text("PDF • \(formattedDate)")
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//
//                Text(fileSizeString)
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            }
//
//            Spacer()
//
//            // Selection Indicator
//            if isMergeMode {
//                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
//                    .foregroundColor(isSelected ? .blue : .gray)
//                    .font(.title2)
//            }
//        }
//        .padding(.vertical, 8)
//        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
//        .cornerRadius(12)
//    }
//
//    private var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
//        return formatter.string(from: document.creationDate ?? Date())
//    }
//
//    private var fileSizeString: String {
//        do {
//            let attributes = try FileManager.default.attributesOfItem(atPath: document.fileURL?.path ?? "")
//            if let fileSize = attributes[.size] as? Int64 {
//                return ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
//            }
//        } catch {
//            print("Ошибка получения размера файла: \(error)")
//        }
//        return "Неизвестный размер"
//    }
//}
//
//// MARK: - Supporting Views
//struct LoadingOverlay: View {
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.1)
//                .ignoresSafeArea()
//
//            ProgressView()
//                .padding()
//                .background(.regularMaterial)
//                .cornerRadius(12)
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    NavigationView {
////        SavedDocsView(viewModel: SavedDocsViewModel(context: NSManagedObjectContext))
//    }
//}
//
