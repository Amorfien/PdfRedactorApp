//
//  WelcomeView.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject private var viewModel: WelcomeViewModel
    @State private var navigateToGenerator = false

    init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                contentView
                NavigationLink(
                    destination: DocGeneratorView(),
                    isActive: $navigateToGenerator,
                    label: { EmptyView() }
                )
                .hidden()
            }
            //                .navigationTitle("PDF Redactor")
            //                .navigationBarTitleDisplayMode(.large)
        }
    }


    private var contentView: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection
                featuresList
                actionButton
            }
            .padding()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .symbolRenderingMode(.hierarchical)

            Text("Добро пожаловать в PDF Redactor")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
    }

    private var featuresList: some View {
        LazyVStack(alignment: .leading, spacing: 16) {
            ForEach(viewModel.features) { feature in
                FeatureRow(feature: feature)
            }
        }
    }

    private var actionButton: some View {
        Button(action: {
            viewModel.nextButtonDidTap()
            navigateToGenerator = true
        }) {
            Text("Начать работу")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
    }

}


// MARK: - Supporting Views
struct FeatureRow: View {
    let feature: WelcomeFeature

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            Image(systemName: feature.icon)
                .font(.title3)
                .foregroundColor(.secondary)
                .frame(width: 24)
                .symbolRenderingMode(.hierarchical)

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(feature.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    WelcomeView(viewModel: WelcomeViewModel())
}
