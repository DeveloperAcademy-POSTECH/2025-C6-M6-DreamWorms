//
//  FullScreenPhotoPicker.swift
//  SUSA24-iOS
//
//  Created by mini on 11/3/25.
//

import PhotosUI
import SwiftUI

struct FullScreenPhotoPicker: UIViewControllerRepresentable {
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: FullScreenPhotoPicker
        init(_ parent: FullScreenPhotoPicker) { self.parent = parent }

        func picker(_: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            defer { parent.isPresented.wrappedValue = false }

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { object, _ in
                if let image = object as? UIImage,
                   let data = image.jpegData(compressionQuality: 1.0)
                {
                    Task { @MainActor in
                        self.parent.onPicked(image, data)
                    }
                }
            }
        }
    }

    let isPresented: Binding<Bool>
    var onPicked: (UIImage, Data) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        picker.modalPresentationStyle = .fullScreen
        
        return picker
    }

    func updateUIViewController(_: PHPickerViewController, context _: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }
}
