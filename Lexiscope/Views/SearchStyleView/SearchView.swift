//
//  SearchView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack {
            ZStack {
                if viewModel.cameraSearch {
                    CameraView()
                } else {
                    AudioView()
                }
                 
                HStack {
                    Spacer()
                    SearchStyleToggleView()
                }
            }
//            .frame(width: CameraViewModel.cameraSize.width,
//                   height: CameraViewModel.cameraSize.height)
            .mask {
                RoundedRectangle(cornerRadius: 20)
                /// Note: Putting the shadow modifier here allows the original view to pass through from the shadow. The mask modifier applies any opacity of the masking view.
            }
            .clipped()

            SearchToolbar()
        }
        .background(.gray)
        .mask {
            RoundedRectangle(cornerRadius: 20)
        }
        .clipped()
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
