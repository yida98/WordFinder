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
    @Published var individualWords: [String]?
    @Published var selectedWordIndex: Int? {
        didSet {
            if let selectedWordIndex = selectedWordIndex,
                let individualWords = individualWords,
                selectedWordIndex < individualWords.count {
                let word = individualWords[selectedWordIndex]
                selectedWordPublisher.send(word)
            }
        }
    }
    var cameraViewportSize: CGSize
    var wordStreamSubscriber: Set<AnyCancellable>
    private var selectedWordPublisher: PassthroughSubject<String, Never>
    
    var searchingToggle: AnyPublisher<Bool, Never>
    var searchingToggleSubscriber: AnyCancellable?
    
    private var cameraViewModel: CameraViewModel?
    
    init(cameraViewportSize: CGSize, searchOpen: AnyPublisher<Bool, Never>) {
        self.cameraViewportSize = cameraViewportSize
        self.wordStreamSubscriber = Set<AnyCancellable>()
        self.selectedWordPublisher = PassthroughSubject<String, Never>()
        self.searchingToggle = searchOpen
        
        self.searchingToggleSubscriber = searchingToggle.sink(receiveValue: toggleSearch(_:))
        WordSearchRequestManager.shared.clusterStream().sink(receiveValue: handleNewRequest(_:)).store(in: &wordStreamSubscriber)
        WordSearchRequestManager.shared.addPublisher(selectedWordPublisher.eraseToAnyPublisher())
    }
    
    func makeCameraViewModel() -> CameraViewModel {
        return CameraViewModel(cameraViewportSize: cameraViewportSize, cameraOn: searchingToggle)
    }
    
    func getCameraViewModel() -> CameraViewModel {
        if cameraViewModel != nil {
            return cameraViewModel!
        }
        cameraViewModel = makeCameraViewModel()
        return cameraViewModel!
    }
    
    func handleNewRequest(_ resultCluster: String?) {
        guard let resultCluster = resultCluster else { return }
        individualWords = resultCluster.split(usingRegex: "[^A-Za-zÀ-ÖØ-öø-ÿ-]")
        individualWords = individualWords?.filter { $0.hasAtLeastOneChar() }
        selectedWordIndex = estimatedSelectionIndex()
    }
    
    private func estimatedSelectionIndex() -> Int {
        guard let individualWords = individualWords else { return 0 }
        let length = individualWords.flatMap { $0 }.count
        let estimatedSelectionRatio = getCameraViewModel().getLocationOfInterest().x
        let estimatedSelectionValue: Int = Int(CGFloat(length) * estimatedSelectionRatio)
        var partialLength: Int = 0
        var wordIndex: Int = 0
        while wordIndex < individualWords.count {
            partialLength += individualWords[wordIndex].count
            if partialLength >= estimatedSelectionValue {
                break
            }
            wordIndex += 1
        }
        return wordIndex
    }
    
    func handleTap(at index: Int) {
        selectedWordIndex = index
    }
    
    func toggleSearch(_ value: Bool) {
        if value {
            cameraViewModel?.resumeCamera()
        } else {
            cameraViewModel?.stopCamera()
        }
    }
}

extension String {
    func split(usingRegex pattern: String) -> [String] {
        let regex = try? NSRegularExpression(pattern: pattern)
        guard let regex = regex else { return [] }
        let matches = regex.matches(in: self, range: NSRange(startIndex..., in: self))
        var result = [String]()
        var position = startIndex
        for match in matches {
            guard let range = Range(match.range, in: self) else { return result }
            result.append(String(self[position..<range.lowerBound]))
            position = range.upperBound
        }
        result.append(String(self[position..<endIndex]))
        return result.filter { !$0.isEmpty }
    }
    
    func hasAtLeastOneChar() -> Bool {
        if self.range(of: "[A-Za-zÀ-ÖØ-öø-ÿ]+", options: .regularExpression) != nil {
            return true
        }
        return false
    }
}
