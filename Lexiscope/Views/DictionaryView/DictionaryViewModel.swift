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
    private var savedWordsViewModel: SavedWordsViewModel?
    
    var wordStreamSubscriber: Set<AnyCancellable>
    @Published var retrieveEntry: RetrieveEntry?
    
    init() {
        self.showingVocabulary = true
        self.wordStreamSubscriber = Set<AnyCancellable>()
        subscribeToWordRequestStream()
    }
    
    func makeDefinitionViewModel(with headwordEntry: HeadwordEntry) -> DefinitionViewModel {
        DefinitionViewModel(headwordEntry: headwordEntry)
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
    
    func handleNewRequest(_ word: String?) {
        endEditing()
        guard let word = word, word.count > 0 else { return }
        URLTask.shared.define(word: word)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                debugPrint("completed \(word)")
            }, receiveValue: { [weak self] retrieveEntry in
                self?.retrieveEntry = retrieveEntry.1
                self?.showingVocabulary = false
            })
            .store(in: &wordStreamSubscriber)
    }
    
    func retrieveEntryResults() -> [HeadwordEntry] {
        return self.retrieveEntry?.results ?? []
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
