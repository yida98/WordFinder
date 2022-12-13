//
//  CameraView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2022-05-03.
//

import SwiftUI
import AVFoundation
import Combine
import Vision

struct CameraView: View {
    
    @ObservedObject var viewModel: CameraViewModel
    
    var body: some View {
        if #available(iOS 16.0, *) {
            ZStack {
                ZStack {
                    CameraViewRepresentable(viewModel: viewModel)
                        .fixedSize(horizontal: false, vertical: true)
                    if let capturedImage = viewModel.capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                if #available(iOS 16.0, *) {
                    ScannerView(viewModel: viewModel.getScannerModel())
                        .frame(width: viewModel.cameraViewportSize.width,
                               height: viewModel.cameraViewportSize.height)
                } else {
                    // Fallback on earlier versions
                }
            }
            .onTapGesture(coordinateSpace: .local) { location in
                viewModel.handleCameraViewTap(at: location)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}
