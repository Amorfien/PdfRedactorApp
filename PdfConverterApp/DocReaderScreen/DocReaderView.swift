//
//  DocReaderView.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 17.09.2025.
//

import SwiftUI
import PDFKit

struct DocReaderView: View {
    @ObservedObject private var viewModel: DocReaderViewModel
    @Environment(\.presentationMode) private var presentationMode
    @State private var showShareSheet = false

    init(viewModel: DocReaderViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            if viewModel.isLoading {
                ProgressView("Загрузка документа...")
            } else if viewModel.pdfDocument != nil {
                ZStack {
                    contentView
                    VStack {
                        HStack(spacing: 20) {
                            Spacer()
                            shareButton
                            if viewModel.fromGenerator {
                                saveButton
                            }
                        }
                        .padding(16)
                        Spacer()
                    }
                }
            } else {
                errorView
            }
        }
        .navigationTitle("Просмотр PDF")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Ошибка", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
        }
        .alert("Удалить страницу?", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Удалить", role: .destructive) {
                if let pageIndex = viewModel.pageToDelete {
                    viewModel.deletePage(at: pageIndex)
                }
            }
            Button("Отмена", role: .cancel) {
                viewModel.pageToDelete = nil
            }
        } message: {
            Text("Вы уверены, что хотите удалить эту страницу?")
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = viewModel.sharePDF() {
                ShareSheet(activityItems: [url])
            }
        }
    }

    private var contentView: some View {
        VStack(spacing: 0) {
            PDFViewer(document: viewModel.pdfDocument, currentPage: $viewModel.currentPageIndex)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            controlsSection

            if viewModel.totalPages > 1 {
                pageThumbnailsSection
            }
        }
    }

    private var controlsSection: some View {
        HStack {
            Button(action: viewModel.goToPreviousPage) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .padding()
                    .disabled(viewModel.currentPageIndex == 0)
            }
            .disabled(viewModel.currentPageIndex == 0)

            Text("Страница \(viewModel.currentPageIndex + 1) из \(viewModel.totalPages)")
                .font(.headline)
                .frame(maxWidth: .infinity)

            Button(action: viewModel.goToNextPage) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .padding()
                    .disabled(viewModel.currentPageIndex >= viewModel.totalPages - 1)
            }
            .disabled(viewModel.currentPageIndex >= viewModel.totalPages - 1)
        }
        .padding(.horizontal)
        .background(Color.gray.opacity(0.1))
    }

    private var pageThumbnailsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(viewModel.pageIndices, id: \.self) { index in
                    PageThumbnailView(
                        viewModel: viewModel,
                        pageIndex: index,
                        isCurrent: index == viewModel.currentPageIndex
                    )
                    .onTapGesture {
                        viewModel.goToPage(index)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.requestDeletePage(at: index)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .frame(height: 100)
        .background(Color.gray.opacity(0.05))
    }

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)

            Text("Не удалось загрузить документ")
                .font(.headline)

            Text(viewModel.errorMessage ?? "Неизвестная ошибка")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("Попробовать снова") {
                viewModel.loadPDFDocument()
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .padding()
    }

    private var shareButton: some View {
        Button(action: {
            showShareSheet = true
        }) {
            Image(systemName: "square.and.arrow.up")
                .padding(10)
                .background(Color.gray.opacity(0.5))
                .clipShape(Capsule())
        }
    }

    private var saveButton: some View {
        Button(action: {
            viewModel.saveToDb()
        }) {
            Image(systemName: "square.and.arrow.down")
                .padding(10)
                .background(Color.gray.opacity(0.5))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Supporting Views
struct PDFViewer: UIViewRepresentable {
    let document: PDFDocument?
    @Binding var currentPage: Int

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        pdfView.document = document
        if let page = document?.page(at: currentPage) {
            pdfView.go(to: page)
        }
    }
}

struct PageThumbnailView: View {
    let viewModel: DocReaderViewModel
    let pageIndex: Int
    let isCurrent: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let thumbnail = viewModel.getThumbnailForPage(at: pageIndex) {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 80)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(isCurrent ? Color.blue : Color.clear, lineWidth: 2)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 80)
                    .cornerRadius(4)
            }

            Text("\(pageIndex + 1)")
                .font(.caption2)
                .foregroundColor(.white)
                .padding(4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(3)
                .padding(2)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview
#Preview {
    let url: URL = URL(string: "https://disk.sample.cat/samples/pdf/sample-images-fit.pdf")!

    NavigationView {
        DocReaderView(viewModel: DocReaderViewModel(pdfData: (PDFDocument(url: url)?.dataRepresentation())!))
    }
}
