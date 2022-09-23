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
        if !viewModel.isRunning {
            viewModel.startRunning()
        }
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
    
    private var loaded = false
    
    override func layoutSubviews() {
        if !loaded {
            self.frame.size = CGSize(width: Constant.screenBounds.width,
                                     height: Constant.screenBounds.width * CameraViewModel.bufferRatio)
            setup()
        }
        super.layoutSubviews()
    }
    
    func setup() {
        if let previewLayer = viewModel.startLiveVideo() {
            loaded = true
            
            previewLayer.frame = self.frame
            self.layer.insertSublayer(previewLayer, at: 0)
        }
    }

}
