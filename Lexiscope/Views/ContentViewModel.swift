//
//  ContentViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/20/22.
//

import Foundation

class ContentViewModel: ObservableObject {
    private var dictionaryViewModel: DictionaryViewModel?
    private var searchViewModel: SearchViewModel?
    private var quizViewModel: QuizViewModel?
    private var cameraViewportSize: CGSize
    private var searchViewMaxHeight: CGFloat
    private var searchViewMinHeight: CGFloat
    @Published var searchViewActiveOffset: CGFloat
    @Published var searchOpen: Bool {
        didSet {
            if allowsCameraUsage {
                searchViewActiveOffset = searchOpen ? searchViewMaxHeight : searchViewMinHeight
                shouldFogCamera = !searchOpen
            }
        }
    }
    
    @Published var shouldFogCamera: Bool {
        didSet {
            if shouldFogCamera {
                getSearchViewModel().getCameraViewModel().stopCamera()
            } else {
                getSearchViewModel().getCameraViewModel().resumeCamera()
            }
        }
    }
    
    @Published var isPresentingQuiz: Bool {
        didSet {
            NotificationCenter.default.post(name: .fogCamera, object: nil, userInfo: ["shouldFog": isPresentingQuiz])
            if !isPresentingQuiz {
                self.quizViewModel = nil
            }
        }
    }
    
    @Published var allowsCameraUsage: Bool = false
    
    init() {
        let cameraViewportHeight = Constant.screenBounds.height / 4
        self.cameraViewportSize = CGSize(width: Constant.screenBounds.width,
                                         height: cameraViewportHeight)
        self.searchViewMaxHeight = cameraViewportHeight - 10
        self.searchViewMinHeight = searchViewMaxHeight * 0.2
        self.searchViewActiveOffset = searchViewMinHeight
        self.searchOpen = false
        self.shouldFogCamera = true
        self.isPresentingQuiz = false
        
        CameraViewModel.requestCameraAccess { success in
            DispatchQueue.main.async { [weak self] in
                self?.allowsCameraUsage = success
            }
        }
        
        setupNotifications()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(fogCamera), name: .fogCamera, object: nil)
    }
    
    @objc
    private func fogCamera(_ notification: NSNotification) {
        if let userInfo = notification.userInfo, let shouldFog = userInfo["shouldFog"] as? Bool {
            shouldFogCamera = shouldFog || !searchOpen
        }
    }
    
    func getDictionaryViewModel() -> DictionaryViewModel {
        if dictionaryViewModel == nil {
            dictionaryViewModel = DictionaryViewModel()
        }
        return dictionaryViewModel!
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
    
    var currentlyQuizzing: [VocabularyEntry]?
    func getQuizViewModel(with entries: [VocabularyEntry]) -> QuizViewModel {
        if quizViewModel == nil {
            let vm = QuizViewModel(dateOrderedVocabularyEntries: entries)
            currentlyQuizzing = entries
            quizViewModel = vm
        }
        return quizViewModel!
    }
    
    func dismissQuiz() {
        if let entries = currentlyQuizzing {
            for entry in entries {
                DataManager.shared.resaveVocabularyEntry(entry)
            }
        }
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
    
    // MARK: - Quiz
    
    func openQuiz() {
        isPresentingQuiz = true
    }
}


extension Notification.Name {
    static var fogCamera: Notification.Name { .init("fogCamera") }
}
