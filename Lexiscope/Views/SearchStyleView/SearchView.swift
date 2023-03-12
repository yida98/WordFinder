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
        VStack(spacing: 0) {
            ZStack {
                CameraView(viewModel: viewModel.getCameraViewModel())
            }
            .frame(height: viewModel.cameraViewportSize.height)
            .contentShape(Rectangle())

            SearchToolbar(viewModel: viewModel)
                .background(.ultraThinMaterial)
        }
        .frame(width: viewModel.cameraViewportSize.width)
        .background(Color.verdigrisDark) // primaryDark
        .clipped()
    }
}
