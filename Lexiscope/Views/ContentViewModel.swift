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
    private var searchViewMaxHeight: CGFloat
    private var searchViewMinHeight: CGFloat
    @Published var searchViewActiveOffset: CGFloat
    @Published var searchOpen: Bool {
        didSet {
            searchViewActiveOffset = searchOpen ? searchViewMaxHeight : searchViewMinHeight
        }
    }
    
    init() {
        let cameraViewportHeight = Constant.screenBounds.height / 3
        self.cameraViewportSize = CGSize(width: Constant.screenBounds.width,
                                         height: cameraViewportHeight)
        self.searchToolbarHeight = 40
        self.searchViewMaxHeight = cameraViewportHeight + searchToolbarHeight
        self.searchViewMinHeight = searchViewMaxHeight * 0.35
        self.searchViewActiveOffset = searchViewMaxHeight
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
    
    // MARK: - Offset
    
    var offsetGive: CGFloat {
        return searchViewMinHeight / 2
    }
    
    func offsetIsValid(_ offset: CGFloat) -> Validity {
        let activeSearchViewHeight = getCurrentStaticOffset() + offset
        if activeSearchViewHeight > searchViewMaxHeight {
            if activeSearchViewHeight - searchViewMaxHeight > offsetGive {
                return .invalid
            } else {
                return .almostInvalid
            }
        } else if activeSearchViewHeight < searchViewMinHeight {
            if activeSearchViewHeight > 0 {
                return .almostInvalid
            } else {
                return .invalid
            }
        } else {
            if activeSearchViewHeight + offsetGive > searchViewMaxHeight || activeSearchViewHeight - offsetGive < 0 {
                return .almostValid
            }
            return .valid
        }
    }
    
    func shouldToggle(_ offset: CGFloat) -> Bool {
        let searchViewHeight = getCurrentStaticOffset() + offset
        if searchOpen && searchViewHeight < (searchViewMinHeight + offsetGive) ||
            !searchOpen && searchViewHeight > (searchViewMaxHeight - offsetGive) {
            return true
        }
        return false
    }
    
    private var movementRetardantModifier: CGFloat = 0.4
    
    func offsetMoveModifier(for offset: CGFloat) -> CGFloat {
        let validity = offsetIsValid(offset)
        switch validity {
        case .almostValid, .valid:
            return movementRetardantModifier
        case .almostInvalid, .invalid:
            let searchViewHeight = getCurrentStaticOffset() + offset
            if offset > 0 {
                let offsetOverShoot = searchViewHeight - searchViewMaxHeight
                let output = (1 - (offsetOverShoot / Constant.screenBounds.height)) * movementRetardantModifier
                return output
            }
            let offsetOverShoot = offsetGive - searchViewHeight
            let output = (1 - (offsetOverShoot / Constant.screenBounds.height)) * movementRetardantModifier
            return output
        }
    }
    
    enum Validity {
        case almostValid
        case valid
        case almostInvalid
        case invalid
    }
    
    func getCurrentStaticOffset() -> CGFloat {
        if searchOpen {
            return searchViewMaxHeight
        }
        return searchViewMinHeight
    }
    
    func resetOffset() {
        searchViewActiveOffset = getCurrentStaticOffset()
    }
}
