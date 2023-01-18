//
//  DictionaryViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/15/22.
//

import Foundation
import Combine
import SwiftUI

class DictionaryViewModel: ObservableObject {
    @Published var showingVocabulary: Bool
    private var definitionViewModel: DefinitionViewModel?
    
    var wordStreamSubscriber: Set<AnyCancellable>
    var searchingHeadwordEntry: HeadwordEntry?
    
    init() {
        self.showingVocabulary = true
        self.wordStreamSubscriber = Set<AnyCancellable>()
        subscribeToWordRequestStream()
    }
    
    func getDefinitionViewModel() -> DefinitionViewModel {
        if definitionViewModel == nil {
            definitionViewModel = DefinitionViewModel()
        }
        return definitionViewModel!
    }
    
    func subscribeToWordRequestStream() {
        WordSearchRequestManager.shared.stream().sink(receiveValue: handleNewRequest(_:)).store(in: &wordStreamSubscriber)
    }
    
    private func handleNewRequest(_ word: String?) {
        guard let word = word else { return }
        URLTask.shared.define(word: word)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                debugPrint("completed \(word)")
            }, receiveValue: { [weak self] entry in
                self?.searchingHeadwordEntry = entry
                self?.showingVocabulary = false
                self?.definitionViewModel?.headwordEntry = entry
            })
            .store(in: &wordStreamSubscriber)
    }
}
