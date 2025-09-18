//
//  Extensions.swift
//  PdfConverterApp
//
//  Created by Pavel Grigorev on 18.09.2025.
//

import SwiftUI

extension View {
    func imagePicker(
        isPresented: Binding<Bool>,
        sourceType: UIImagePickerController.SourceType,
        onImageSelected: @escaping (UIImage) -> Void,
        onCancel: @escaping () -> Void = {}
    ) -> some View {
        self.sheet(isPresented: isPresented) {
            ImagePicker(
                isPresented: isPresented,
                sourceType: sourceType,
                onImageSelected: onImageSelected,
                onCancel: onCancel
            )
        }
    }
}
