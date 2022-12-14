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
    @Published var individualWords: [String]
    @Published var selectedWordIndex: Int
    var cameraViewportSize = CGSize(width: Constant.screenBounds.width - 30, height: 200)
    var wordStreamSubscriber: Set<AnyCancellable>
    private var cameraViewModel: CameraViewModel
    
    init() {
        self.cameraSearch = true
        self.wordSearchRequest = ""
        self.individualWords = [String]()
        self.selectedWordIndex = 0
        self.wordStreamSubscriber = Set<AnyCancellable>()
        self.cameraViewModel = CameraViewModel(cameraViewportSize: cameraViewportSize)
        WordSearchRequestManager.shared.stream().sink(receiveValue: handleNewRequest(_:)).store(in: &wordStreamSubscriber)
    }
    
    func getCameraViewModel() -> CameraViewModel {
        return cameraViewModel
    }
    
    func handleNewRequest(_ resultCluster: String) {
        individualWords = resultCluster.split(usingRegex: "[^A-Za-zÀ-ÖØ-öø-ÿ-]")
        selectedWordIndex = estimatedSelectionIndex()
    }
    
    private func estimatedSelectionIndex() -> Int {
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
}
