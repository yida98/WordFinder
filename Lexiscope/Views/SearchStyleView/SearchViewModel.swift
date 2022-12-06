//
//  SearchViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import Foundation

class SearchViewModel: ObservableObject {
    // TODO: Persist default
    @Published var cameraSearch: Bool = true
    var cameraViewportSize = CGSize(width: Constant.screenBounds.width, height: 200)
    
    init() {
        
    }
    
    func getCameraViewModel() -> CameraViewModel {
        return CameraViewModel(cameraViewportSize: cameraViewportSize)
    }
}
