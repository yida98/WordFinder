//
//  DictionaryViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/15/22.
//

import Foundation
import Combine
import SwiftUI

class DictionaryViewModel: ObservableObject, SavedWordsVocabularyDelegate {
    @Published var showingVocabulary: Bool
    private var savedWordsViewModel: SavedWordsViewModel?
    
    var wordStreamSubscriber: Set<AnyCancellable>
    @Published var retrieveEntry: RetrieveEntry?
    @Published var vocabularySize: Int
    var dataManagerSubscriber: AnyCancellable?
    
    @Published var filterFamiliar: Bool
    @Published var textFilter: String
    
    init() {
        self.showingVocabulary = true
        self.wordStreamSubscriber = Set<AnyCancellable>()
        self.vocabularySize = DataManager.shared.fetchVocabulary()?.count ?? 0
        self.filterFamiliar = false
        self.textFilter = ""
        
        self.retrieveResultsDefinitionVMs = [DefinitionViewModel]()
        
        self.dataManagerSubscriber = DataManager.shared.objectWillChange.sink { [weak self] _ in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.vocabularySize = DataManager.shared.fetchVocabulary()?.count ?? 0
                strongSelf.recheckRetrieveSaved()
            }
        }
        subscribeToWordRequestStream()
    }
    
    var retrieveResultsDefinitionVMs: [DefinitionViewModel]
    
    func makeDefinitionViewModel(with headwordEntry: HeadwordEntry) -> DefinitionViewModel {
        if let vocabularyEntry = DataManager.shared.fetchVocabularyEntry(for: headwordEntry) {
            let fetchedHeadwordEntry = DataManager.decodedHeadwordEntryData(vocabularyEntry.headwordEntry!)
            let saved = HeadwordEntry.areSame(lhs: fetchedHeadwordEntry, rhs: headwordEntry)
            return DefinitionViewModel(headwordEntry: headwordEntry, saved: saved, expanded: true)
        }
        return DefinitionViewModel(headwordEntry: headwordEntry, saved: false, expanded: true)
    }
    
    func recheckRetrieveSaved() {
        for retrieve in retrieveResultsDefinitionVMs {
            if let vocabularyEntry = DataManager.shared.fetchVocabularyEntry(for: retrieve.headwordEntry), let headwordData = vocabularyEntry.headwordEntry {
                let fetchedHeadwordEntry = DataManager.decodedHeadwordEntryData(headwordData)
                let saved = HeadwordEntry.areSame(lhs: fetchedHeadwordEntry, rhs: retrieve.headwordEntry)
                retrieve.saved = saved
            } else {
                retrieve.saved = false
            }
        }
    }
    
    func getSavedWordsViewModel() -> SavedWordsViewModel {
        if savedWordsViewModel == nil {
            savedWordsViewModel = SavedWordsViewModel(filterFamiliarPublisher: $filterFamiliar.eraseToAnyPublisher(), shouldFilterFamiliar: filterFamiliar, textFilterPublisher: $textFilter.eraseToAnyPublisher(), textFilter: textFilter)
            savedWordsViewModel?.savedWordsVocabularyDelegate = self
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
                guard let strongSelf = self else { return }
                strongSelf.retrieveEntry = retrieveEntry.1
                strongSelf.makeViewModels(for: strongSelf.retrieveEntryResults())
                strongSelf.showingVocabulary = false
            })
            .store(in: &wordStreamSubscriber)
    }
    
    private func makeViewModels(for headwordEntries: [HeadwordEntry]) {
        retrieveResultsDefinitionVMs = [DefinitionViewModel]()
        for headwordEntry in headwordEntries {
            retrieveResultsDefinitionVMs.append( makeDefinitionViewModel(with: headwordEntry))
        }
    }
    
    func toggleExpanded(at index: Int) {
        guard index < retrieveResultsDefinitionVMs.count else { return }
        retrieveResultsDefinitionVMs[index].expanded.toggle()
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
    
    func vocabularyDidUpdate(_ vocabulary: [VocabularyEntry]) {
        vocabularySize = vocabulary.flatMap { $0 }.count
    }
}

protocol SavedWordsVocabularyDelegate {
    func vocabularyDidUpdate(_ vocabulary: [VocabularyEntry])
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
