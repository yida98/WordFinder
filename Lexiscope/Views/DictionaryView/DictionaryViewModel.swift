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
    @Published var showingVocabulary: Bool {
        willSet {
            endEditing()
        }
    }
    @Published var expanded: Bool
    private var definitionViewModel: DefinitionViewModel?
    private var savedWordsViewModel: SavedWordsViewModel?
    
    var wordStreamSubscriber: Set<AnyCancellable>
    var searchingVocabularyEntry: VocabularyEntry?
    
    init() {
        self.showingVocabulary = true
        self.expanded = true
        self.wordStreamSubscriber = Set<AnyCancellable>()
        subscribeToWordRequestStream()
    }
    
    func getDefinitionViewModel() -> DefinitionViewModel {
        if definitionViewModel == nil {
            definitionViewModel = DefinitionViewModel()
        }
        return definitionViewModel!
    }
    
    func getSavedWordsViewModel() -> SavedWordsViewModel {
        if savedWordsViewModel == nil {
            savedWordsViewModel = SavedWordsViewModel()
        }
        return savedWordsViewModel!
    }
    
    func subscribeToWordRequestStream() {
        WordSearchRequestManager.shared.stream().sink(receiveValue: handleNewRequest(_:)).store(in: &wordStreamSubscriber)
    }
    
    private func handleNewRequest(_ word: String?) {
        endEditing()
        guard let word = word, word.count > 0 else { return }
        URLTask.shared.define(word: word)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                debugPrint("completed \(word)")
            }, receiveValue: { [weak self] entry in
                if let vocabularyEntry = DataManager.shared.fetchVocabularyEntry(for: word) as? VocabularyEntry {
                    self?.searchingVocabularyEntry = vocabularyEntry
                    self?.showingVocabulary = false
                    self?.definitionViewModel?.vocabularyEntry = vocabularyEntry
                }
            })
            .store(in: &wordStreamSubscriber)
    }
    
    func searchWord(_ word: String?) {
        handleNewRequest(word)
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
