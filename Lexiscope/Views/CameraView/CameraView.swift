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
            Group {
                CameraViewRepresentable(viewModel: viewModel)
    
                ScannerView()
                    .environmentObject(viewModel)
                    .frame(width: CameraViewModel.viewportSize.width,
                           height: CameraViewModel.viewportSize.height)
                    .overlay(Text(viewModel.word)
                                .foregroundColor(Color.babyPowder)
                                .offset(y: CameraViewModel.viewportSize.height*0.5 + 16))
            } .position(x: Constant.screenBounds.width/2,
                        y: viewModel.trueCameraHeight/2)
            
            DictionaryView()
//                .environmentObject(viewModel)
                .offset(y: viewModel.trueCameraHeight/2 - CameraViewModel.viewFurtherInset)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        viewModel.lookup()
                    } label: {
                        Text("Search")
                            .foregroundColor(.white)
                            .font(Font.custom(Constant.fontName, size: 20))
                            .fontWeight(.semibold)
                    }
                    .frame(width: CameraViewModel.buttonSize.width, height: CameraViewModel.buttonSize.height)
                    .background(Color.darkSkyBlue)
                    .padding(CameraViewModel.buttonPadding)
                    .mask(RoundedRectangle(cornerRadius: CameraViewModel.buttonCornerRadius)
                            .frame(width: CameraViewModel.buttonSize.width, height: CameraViewModel.buttonSize.height))
                }
            }
            AlertView(isPresenting: !viewModel.allowsCameraUsage) {
                Button {
                    Application.shared.openSettings()
                } label: {
                    HStack {
                        Text("Camera disabled in settings")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Image(systemName: "arrowshape.turn.up.right.circle.fill")
                            .foregroundColor(.lightGrey) // TODO: Group colours into primary, secondary etc.
                    }
                }
            }.offset(y: 50)
        }
        .ignoresSafeArea()
    }
}
