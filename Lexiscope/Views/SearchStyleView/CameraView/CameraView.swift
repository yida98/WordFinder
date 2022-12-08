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
        ZStack {
            if let capturedImage = viewModel.capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                CameraViewRepresentable(viewModel: viewModel)
                    .fixedSize(horizontal: false, vertical: true)
            }
            ScannerView()
                .environmentObject(viewModel.getScannerModel())
                .frame(width: viewModel.cameraViewportSize.width,
                       height: viewModel.cameraViewportSize.height)
                .onTapGesture {
                    viewModel.handleCameraViewTap()
                }
        }
    }
}
