//
//  SavedDocsView.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 17.09.2025.
//

import SwiftUI
import CoreData

struct SavedDocsView: View {
    @ObservedObject private var viewModel: SavedDocsViewModel

    init(viewModel: SavedDocsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.documents.isEmpty {
                ProgressView("Загрузка документов...")
            } else if viewModel.documents.isEmpty {
                emptyStateView
            } else {
                documentsListView
            }

            if viewModel.isLoading {
                LoadingOverlay()
            }
        }
        .navigationTitle("Мои документы")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.deleteAll()
                } label: {
                    Image(systemName: "trash")
                }
                .disabled(viewModel.documents.isEmpty)
            }
        }
    }

    private var documentsListView: some View {
        List {
            ForEach(viewModel.documents, id: \.id) { document in
                DocumentCell(document: document)
                .contentShape(Rectangle())
                .onTapGesture {

//              open pdf
                    print("Open")

                }
                .contextMenu {
                    Button(role: .destructive) {
                        viewModel.deleteDocument(document)
                    } label: {
                        Label("Удалить", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("Нет сохраненных документов")
                .font(.headline)
                .foregroundColor(.primary)

            Text("Создайте свой первый PDF документ")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - DocumentCell
struct DocumentCell: View {
    let document: DocEntity

    var body: some View {
        HStack(spacing: 16) {
            // Thumbnail
            if let thumbnailData = document.thumbnail,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 80)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "doc")
                            .foregroundColor(.gray)
                    )
            }

            // Document Info
            VStack(alignment: .leading, spacing: 4) {
                Text(document.name ?? "Без названия")
                    .font(.headline)
                    .lineLimit(1)

                Text("\(document.fileExtension?.uppercased() ?? "Unknown") • \(formattedDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(document.fileSize ?? "Неизвестный размер")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

        }
        .padding(.vertical, 8)
        .background(Color.clear)
        .cornerRadius(12)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: document.creationDate ?? Date())
    }
}

// MARK: - Supporting Views
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()

            ProgressView()
                .padding()
                .background(.regularMaterial)
                .cornerRadius(12)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        SavedDocsView(viewModel: SavedDocsViewModel())
    }
}

