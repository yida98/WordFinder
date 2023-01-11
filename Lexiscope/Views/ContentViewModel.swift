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
    @Published var searchOpen: Bool {
        didSet {
            searchViewOffset = searchOpen ? searchViewOffset / 0.35 : searchViewOffset * 0.35
        }
    }
    
    init() {
        let cameraViewportHeight = Constant.screenBounds.height / 3
        self.cameraViewportSize = CGSize(width: Constant.screenBounds.width,
                                         height: cameraViewportHeight)
        self.searchToolbarHeight = 40
        self.searchViewOffset = cameraViewportHeight + searchToolbarHeight
        self.searchOpen = true
    }
    
    func getSearchViewModel() -> SearchViewModel {
        var searchVM: SearchViewModel
        if searchViewModel == nil {
            searchVM = SearchViewModel(cameraViewportSize: cameraViewportSize, searchOpen: $searchOpen.eraseToAnyPublisher())
            searchViewModel = searchVM
        } else {
            searchVM = searchViewModel!
        }
        return searchVM
    }
}
