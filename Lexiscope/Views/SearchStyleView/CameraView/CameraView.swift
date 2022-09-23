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
    
    @StateObject var viewModel: CameraViewModel = CameraViewModel()
    
    var body: some View {
        ZStack {
            CameraViewRepresentable(viewModel: viewModel)
                .onTapGesture {
                    viewModel.takePhoto()
                }
            ScannerView()
                .environmentObject(viewModel)
                .frame(width: CameraViewModel.viewportSize.width,
                       height: CameraViewModel.viewportSize.height)
                .overlay(Text(viewModel.word)
                            .foregroundColor(Color.babyPowder)
                            //.offset(y: CameraViewModel.viewportSize.height*0.5 + 16) // FIXME: Correct offset
                )
        }
    }
}
