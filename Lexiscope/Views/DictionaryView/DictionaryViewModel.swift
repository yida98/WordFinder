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
    @UIApplicationDelegateAdaptor var appData: AppData
    
    @Published var showingVocabulary: Bool
    private var savedWordsViewModel: SavedWordsViewModel?
    
    var wordStreamSubscriber: Set<AnyCancellable>
    @Published var retrieveEntry: MWRetrieveEntries?
    @Published var vocabularySize: Int
    var dataManagerSubscriber: AnyCancellable?
    
    @Published var suggestions: [String]?
    
    @Published var filterFamiliar: Bool
    @Published var textFilter: String
    
    init() {
        self.showingVocabulary = true
        self.wordStreamSubscriber = Set<AnyCancellable>()
        self.vocabularySize = DataManager.shared.fetchVocabulary()?.count ?? 0
        self.filterFamiliar = false
        self.textFilter = ""
        
        self.retrieveResultsDefinitionVMs = [MWRetrieveGroupViewModel]()
        
        self.dataManagerSubscriber = DataManager.shared.objectWillChange.sink { [weak self] _ in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.vocabularySize = DataManager.shared.fetchVocabulary()?.count ?? 0
                strongSelf.recheckRetrieveSaved()
            }
        }
        subscribeToWordRequestStream()
    }
    
    var retrieveResultsDefinitionVMs: [MWRetrieveGroupViewModel]
    
    func makeDefinitionViewModel(with group: MWRetrieveGroup) -> MWRetrieveGroupViewModel {
        if let vocabularyEntry = DataManager.shared.fetchVocabularyEntry(for: group),
            let entry = vocabularyEntry.headwordEntry,
            let fetchedHeadwordEntry = DataManager.decodedData(entry, dataType: appData.currentAPI.headwordType) {
            let saved = fetchedHeadwordEntry == group
            return MWRetrieveGroupViewModel(group: group, saved: saved, expanded: true, fullScreen: false)
        }
        return MWRetrieveGroupViewModel(group: group, saved: false, expanded: true, fullScreen: false)
    }
    
    func recheckRetrieveSaved() {
        for retrieve in retrieveResultsDefinitionVMs {
            if let vocabularyEntry = DataManager.shared.fetchVocabularyEntry(for: retrieve.group),
                let headwordData = vocabularyEntry.headwordEntry,
                let fetchedHeadwordEntry = DataManager.decodedData(headwordData, dataType: appData.currentAPI.headwordType) {
                let saved = fetchedHeadwordEntry == retrieve.group
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
        suggestions = nil
        guard let word = word, word.count > 0 else { return }
        self.textFilter = word
        URLTask.shared.define(word: word)
            .catch({ error in
                if case NetworkError.relatedResults(let relatedResults) = error {
                    DispatchQueue.main.async {
                        self.showingVocabulary = false
                        self.suggestions = relatedResults
                    }
                }
                return Just<(String?, MWRetrieveEntries?)>((nil, nil))
            })
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                debugPrint("completed \(word)")
            }, receiveValue: { [weak self] (retrieveEntry: (String?, MWRetrieveEntries?)) in
                guard let strongSelf = self else { return }
                strongSelf.retrieveEntry = retrieveEntry.1
                strongSelf.showingVocabulary = false
                guard let retrieve = retrieveEntry.1 else { return }
                strongSelf.makeViewModels(for: retrieve)
            })
            .store(in: &wordStreamSubscriber)
    }
    
    private func makeViewModels(for headwordEntries: MWRetrieveEntries) {
        retrieveResultsDefinitionVMs = [MWRetrieveGroupViewModel]()
        for group in headwordEntries.entries {
            retrieveResultsDefinitionVMs.append(makeDefinitionViewModel(with: group))
        }
    }
    
    func toggleExpanded(at index: Int) {
        guard index < retrieveResultsDefinitionVMs.count else { return }
        retrieveResultsDefinitionVMs[index].expanded.toggle()
    }
    
    private func endEditing() {
        UIApplication.shared.endEditing()
    }
    
    func retrieveEntryResultSectionTitles() -> [String] {
        guard let retrieveEntry = retrieveEntry, !retrieveEntry.entries.isEmpty else { return [] }
        var result = [String]()
        for entryIndex in 1...retrieveEntry.entries.count {
            result.append(String(entryIndex))
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

