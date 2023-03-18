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
    @GestureState var tempScale: CGFloat = 1.0
    @State private var realScale: CGFloat = 1.0
    @State private var initialScale: CGFloat = 1.0
    
    var body: some View {
        if #available(iOS 16.0, *) {
            ZStack {
                ZStack {
                    CameraViewRepresentable(viewModel: viewModel)
                        .fixedSize(horizontal: false, vertical: true)
                    Button {
                        var zoom: CGFloat = 1
                        if realScale == 1 {
                            zoom = viewModel.cameraMaxZoomFactor
                        }
                        realScale = zoom
                        initialScale = zoom
                        viewModel.zoom(zoom)
                    } label: {
                        Text(zoomString())
                            .font(.caption)
                            .foregroundStyle(.ultraThinMaterial)
                            .padding(10)
                    }
                    .background(
                        Circle()
                            .fill(.black.opacity(0.2))
                    )
                    .offset(x: (viewModel.cameraViewportSize.width / 2) - 25,
                            y: (viewModel.cameraViewportSize.height / 2) - 25)
                    if let capturedImage = viewModel.capturedImage {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                }
                if viewModel.cameraOn {
                    ScannerView(viewModel: viewModel.getScannerModel())
                        .frame(width: viewModel.cameraViewportSize.width,
                               height: viewModel.cameraViewportSize.height)
                }
            }
            .onTapGesture(coordinateSpace: .local) { location in
                viewModel.handleCameraViewTap(at: location)
            }
            .gesture(
                MagnificationGesture()
                    .updating($tempScale, body: { value, scale, trans in
                        let updatingScale = value * initialScale
                        if updatingScale >= 1 && updatingScale <= viewModel.cameraMaxZoomFactor {
                            scale = updatingScale
                            viewModel.zoom(updatingScale)
                            DispatchQueue.main.async {
                                self.realScale = updatingScale
                            }
                        } else if updatingScale < 1 {
                            scale = 1
                            viewModel.zoom(1)
                            DispatchQueue.main.async {
                                self.realScale = 1
                            }
                        } else if updatingScale > viewModel.cameraMaxZoomFactor {
                            scale = viewModel.cameraMaxZoomFactor
                            viewModel.zoom(viewModel.cameraMaxZoomFactor)
                            DispatchQueue.main.async {
                                self.realScale = self.viewModel.cameraMaxZoomFactor
                            }
                        }
                    })
                    .onEnded({ value in
                        self.initialScale = realScale
                    })
            )
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func zoomString() -> String {
        if realScale < 9 {
            return String(format: "%.1fx", realScale)
        } else {
            return "max"
        }
    }
}
