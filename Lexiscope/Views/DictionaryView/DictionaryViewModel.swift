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
    @Published var vocabularySize: Int
    var dataManagerSubscriber: AnyCancellable?
    
    @Published var isPresentingQuiz: Bool
    
    init() {
        self.showingVocabulary = true
        self.wordStreamSubscriber = Set<AnyCancellable>()
        self.vocabularySize = DataManager.shared.fetchVocabulary()?.count ?? 0
        self.isPresentingQuiz = false
        self.dataManagerSubscriber = DataManager.shared.objectWillChange.sink { [weak self] _ in
            self?.vocabularySize = DataManager.shared.fetchVocabulary()?.count ?? 0
        }
        subscribeToWordRequestStream()
    }
    
    func makeDefinitionViewModel(with headwordEntry: HeadwordEntry) -> DefinitionViewModel {
        if let vocabularyEntry = DataManager.shared.fetchVocabularyEntry(for: headwordEntry.word) as? VocabularyEntry {
            let fetchedHeadwordEntry = DataManager.decodedHeadwordEntryData(vocabularyEntry.headwordEntry!)
            let saved = HeadwordEntry.areSame(lhs: fetchedHeadwordEntry, rhs: headwordEntry)
            return DefinitionViewModel(headwordEntry: headwordEntry, saved: saved, expanded: true)
        }
        return DefinitionViewModel(headwordEntry: headwordEntry, saved: false, expanded: true)
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
    
    func retrieveEntryResultSectionTitles() -> [String] {
        var result = [String]()
        for entryIndex in retrieveEntryResults().indices {
            result.append(String(entryIndex + 1))
        }
        return result
    }
    
    func openQuiz() {
        isPresentingQuiz = true
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension HeadwordEntry {
    static func areSame(lhs: HeadwordEntry, rhs: HeadwordEntry) -> Bool {
        if lhs.lexicalEntries.count != rhs.lexicalEntries.count { return false }
        var lexicalIndex = 0
        var sensesIndex = 0
        
        while lexicalIndex < lhs.lexicalEntries.count {
            let lhsSenses = lhs.lexicalEntries[lexicalIndex].allSenses()
            let rhsSenses = rhs.lexicalEntries[lexicalIndex].allSenses()
            if lhsSenses.count != rhsSenses.count { return false }
            while sensesIndex < lhsSenses.count {
                if lhsSenses[sensesIndex].id != rhsSenses[sensesIndex].id {
                    return false
                }
                sensesIndex += 1
            }
            lexicalIndex += 1
        }
        
        return true
    }
}
