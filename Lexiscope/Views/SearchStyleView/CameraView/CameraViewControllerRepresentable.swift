//
//  CameraViewControllerRepresentable.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/23/22.
//

import Foundation
import Vision
import SwiftUI
import Combine
import AVFoundation

struct CameraViewRepresentable: UIViewRepresentable {
    var viewModel: CameraViewModel
    
    func makeUIView(context: Context) -> CameraScannerView {
        let cameraView = CameraScannerView()
        cameraView.viewModel = viewModel
        return cameraView
    }
    
    /// Updates the state of the specified view with new information from SwiftUI. Same as send.
    func updateUIView(_ uiView: CameraScannerView, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator {
        let parent: CameraViewRepresentable
        
        init(_ parent: CameraViewRepresentable) {
            self.parent = parent
        }
        
    }
}

class CameraScannerView: UIView {
    var viewModel: CameraViewModel!
    
    private var firstLaunch: Bool = true
    
    override func layoutSubviews() {
        if firstLaunch {
            DispatchQueue.global().async {
                self.setup()
            }
        }
        firstLaunch = false
        super.layoutSubviews()
    }
    
    override var intrinsicContentSize: CGSize {
        return CameraViewModel.cameraSize
    }
    
    func setup() {
        viewModel.startCamera()
        if let previewLayer = viewModel.cameraPreviewLayer() {
            DispatchQueue.main.async {
                previewLayer.frame = self.frame
                self.layer.insertSublayer(previewLayer, at: 0)
            }
        }
    }

}
