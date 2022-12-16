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
            .contentShape(Rectangle())
            .clipped()

            SearchToolbar(viewModel: viewModel)
        }
        .frame(width: viewModel.cameraViewportSize.width)
        .background(Color.boyBlue)
        .clipped()
    }
}
