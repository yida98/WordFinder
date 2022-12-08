//
//  SearchStyleToggleView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import SwiftUI

struct SearchStyleToggleView: View {
    @ObservedObject var viewModel: SearchViewModel
    var body: some View {
        VStack {
            SearchIconView(selected: viewModel.cameraSearch, systemName: "camera")
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.3)) {
                        viewModel.cameraSearch = true
                    }
                }
            SearchIconView(selected: !viewModel.cameraSearch, systemName: "mic")
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.3)) {
                        viewModel.cameraSearch = false
                    }
                }
        }
        .padding(5)
        .background(
            Color.black
                .opacity(0.1)
        )
        .mask {
            RoundedRectangle(cornerRadius: .infinity)
        }
    }
}
