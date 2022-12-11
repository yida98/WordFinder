//
//  SearchViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 9/21/22.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    // TODO: Persist default
    @Published var cameraSearch: Bool
    @Published var wordSearchRequest: String
    var cameraViewportSize = CGSize(width: Constant.screenBounds.width, height: 200)
    var wordStreamSubscriber: Set<AnyCancellable>
    private var cameraViewModel: CameraViewModel
    
    init() {
        self.cameraSearch = true
        self.wordSearchRequest = ""
        self.wordStreamSubscriber = Set<AnyCancellable>()
        self.cameraViewModel = CameraViewModel(cameraViewportSize: cameraViewportSize)
        WordSearchRequestManager.shared.stream().assign(to: \.wordSearchRequest, on: self).store(in: &wordStreamSubscriber)
    }
    
    
    func getCameraViewModel() -> CameraViewModel {
        return cameraViewModel
    }
}
