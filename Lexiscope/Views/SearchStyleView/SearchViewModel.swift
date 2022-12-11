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
    var cameraViewportSize = CGSize(width: Constant.screenBounds.width, height: 200)
    var wordStreamSubscriber: Set<AnyCancellable>
    private var cameraViewModel: CameraViewModel
    
    init() {
        self.cameraSearch = true
        self.wordSearchRequest = ""
        self.individualWords = [String]()
        self.wordStreamSubscriber = Set<AnyCancellable>()
        self.cameraViewModel = CameraViewModel(cameraViewportSize: cameraViewportSize)
        WordSearchRequestManager.shared.stream().sink(receiveValue: { [weak self] resultCluster in
            self?.individualWords = resultCluster.split(usingRegex: "[^A-Za-zÀ-ÖØ-öø-ÿ-]")
        }).store(in: &wordStreamSubscriber)
    }
    
    func getCameraViewModel() -> CameraViewModel {
        return cameraViewModel
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
