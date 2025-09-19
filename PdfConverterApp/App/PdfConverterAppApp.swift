//
//  PdfConverterAppApp.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 16.09.2025.
//

import SwiftUI

@main
struct PdfConverterAppApp: App {

    var body: some Scene {
        WindowGroup {
            WelcomeView(viewModel: WelcomeViewModel())
        }
    }
}
