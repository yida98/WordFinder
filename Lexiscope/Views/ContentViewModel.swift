//
//  ContentViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/20/22.
//

import Foundation

class ContentViewModel: ObservableObject {
    private var searchViewModel: SearchViewModel?
    private var cameraViewportSize: CGSize
    private var searchToolbarHeight: CGFloat
    @Published var searchViewOffset: CGFloat
    
    init() {
        let cameraViewportHeight = Constant.screenBounds.height / 3
        self.cameraViewportSize = CGSize(width: Constant.screenBounds.width,
                                         height: cameraViewportHeight)
        self.searchToolbarHeight = 40
        self.searchViewOffset = cameraViewportHeight + 40
    }
    
    func getSearchViewModel() -> SearchViewModel {
        guard searchViewModel != nil else {
            return SearchViewModel(cameraViewportSize: cameraViewportSize)
        }
        return searchViewModel!
    }
}
