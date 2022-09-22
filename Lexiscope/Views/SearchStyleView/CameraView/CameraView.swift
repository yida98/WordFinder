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
//            RoundedRectangle(cornerRadius: 20)
//                .frame(width: Constant.screenBounds.width - 40, height:
//                .frame(width: Constant.screenBounds.width, height: 500)
//                .background(Color.blue)
//                .shadow(radius: 10)
            
            CameraViewRepresentable(viewModel: viewModel)
        }
        .mask {
            RoundedRectangle(cornerRadius: 20)
            /// Note: Putting the shadow modifier here allows the original view to pass through into the shadow. The mask modifier applies any transparency of the masking view.
        }
        .frame(width: Constant.screenBounds.width - 40, height: 150)
        .clipped()
    }
}
