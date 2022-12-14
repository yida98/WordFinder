//
//  SearchView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack {
            ZStack {
                if viewModel.cameraSearch {
                    CameraView(viewModel: viewModel.getCameraViewModel())
                } else {
                    AudioView()
                }
                 
                HStack {
                    Spacer()
                    SearchStyleToggleView(viewModel: viewModel)
                }
            }
            .frame(height: viewModel.cameraViewportSize.height)
            .mask {
                RoundedRectangle(cornerRadius: 20)
                /// Note: Putting the shadow modifier here allows the original view to pass through from the shadow. The mask modifier applies any opacity of the masking view.
            }
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .clipped()

            SearchToolbar(viewModel: viewModel)
                .frame(height: 30)
        }
        .frame(width: viewModel.cameraViewportSize.width)
        .background(Color.boyBlue)
        .mask {
            RoundedRectangle(cornerRadius: 20)
        }
        .clipped()
    }
}
