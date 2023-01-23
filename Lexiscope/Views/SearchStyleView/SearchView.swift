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
                CameraView(viewModel: viewModel.getCameraViewModel())
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
