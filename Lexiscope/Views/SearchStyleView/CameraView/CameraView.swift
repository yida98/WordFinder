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
                    .onTapGesture {
                        viewModel.resumeCamera()
                    }
            } else {
                CameraViewRepresentable(viewModel: viewModel)
                    .fixedSize(horizontal: false, vertical: true)
                    .onTapGesture {
                        viewModel.takePhoto()
                    }
            }
            ScannerView()
                .environmentObject(viewModel.getScannerModel())
                .frame(width: viewModel.cameraViewportSize.width,
                       height: viewModel.cameraViewportSize.height)
                .overlay(Text(viewModel.word)
                            .foregroundColor(Color.babyPowder)
                            //.offset(y: CameraViewModel.viewportSize.height*0.5 + 16) // FIXME: Correct offset
                )
        }
    }
}
