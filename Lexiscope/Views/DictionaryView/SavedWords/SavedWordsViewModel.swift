//
//  SavedWordsViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import Foundation
import SwiftUI
import Combine

class SavedWordsViewModel: ObservableObject {
    
    @Published var vocabulary: [[VocabularyEntry]]?
    @Published var sectionTitles: [String]?
    @Published var vocabularyDictionary: [String: [VocabularyEntry]]?
    @Published var isPresenting: Bool = false
    var dataManager: DataManager
    var presentingVocabularyEntry: VocabularyEntry?
    
    var filterFamiliarPublisher: AnyPublisher<Bool, Never>
    private var shouldFilterFamiliar: Bool
    var textFilterPublisher: AnyPublisher<String, Never>
    private var textFilter: String
    
    private var dataSubscribers = Set<AnyCancellable>()
    
    var savedWordsVocabularyDelegate: SavedWordsVocabularyDelegate?
    
    init(filterFamiliarPublisher: AnyPublisher<Bool, Never>, shouldFilterFamiliar: Bool, textFilterPublisher: AnyPublisher<String, Never>, textFilter: String) {
        self.dataManager = DataManager.shared
        self.filterFamiliarPublisher = filterFamiliarPublisher
        self.shouldFilterFamiliar = shouldFilterFamiliar
        self.textFilterPublisher = textFilterPublisher
        self.textFilter = textFilter
        
        filterFamiliarPublisher.sink { [weak self] shouldFilter in
            self?.shouldFilterFamiliar = shouldFilter
            self?.fetchVocabList()
        }.store(in: &dataSubscribers)
        
        textFilterPublisher.sink { [weak self] filter in
            self?.textFilter = filter
            self?.fetchVocabList()
        }.store(in: &dataSubscribers)
        
        dataManager.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.isPresenting = false
            }
            self?.fetchVocabList()
        }.store(in: &dataSubscribers)
        fetchVocabList()
    }
    
    private func fetchVocabList() {
        guard var savedVocabulary = DataManager.shared.fetchVocabulary() as? [VocabularyEntry] else {
            return
        }
        
        if shouldFilterFamiliar, let familiarFilter = DataManager.shared.fetchAllFamiliar() {
            savedVocabulary = vocabularyWithFilter(original: savedVocabulary, familiarFilter.compactMap { $0.word })
        }
        
        if !textFilter.isEmpty {
            savedVocabulary = savedVocabulary.filter {
                if let word = $0.word {
                    return word.lowercased().hasPrefix(textFilter.lowercased())
                }
                return false
            }
        }
        
        setVocabulary(with: savedVocabulary)
    }
    
    private func vocabularyWithFilter(original: [VocabularyEntry], _ filter: [String]) -> [VocabularyEntry] {
        var results = [VocabularyEntry]()
        let currentVocabularyWords = original.compactMap { $0.word }
        let unorderedFilteredVocabulary = Set(currentVocabularyWords).intersection(Set(filter))
        for v in original {
            if unorderedFilteredVocabulary.contains(v.word ?? "") {
                results.append(v)
            }
        }
        return results
    }
    
    private func setVocabulary(with vocabulary: [VocabularyEntry]) {
        DispatchQueue.main.async { [weak self] in
            self?.vocabularyDictionary = SavedWordsViewModel.alphabetizedDictionary(for: vocabulary)
            self?.vocabulary = SavedWordsViewModel.alphabetizedVocabulary(for: vocabulary)
            self?.sectionTitles = SavedWordsViewModel.alphabetizedKeys(for: vocabulary).map { String($0) }
            if let delegate = self?.savedWordsVocabularyDelegate {
                delegate.vocabularyDidUpdate(vocabulary)
            }
        }
    }
    
    static func alphabetizedDictionary(for vocabulary: [VocabularyEntry]) -> [String: [VocabularyEntry]] {
        /// Vocabulary entry's word can be both capitalized or not
        var dict = [String: [VocabularyEntry]]()
        for vocabularyEntry in vocabulary {
            let firstLetter = String(vocabularyEntry.word!.lowercased().first!)
            if dict.keys.contains(firstLetter) {
                var array = dict[firstLetter]
                array!.append(vocabularyEntry)
                array!.sort(by: { $0.word!.lowercased() < $1.word!.lowercased() })
                dict[firstLetter] = array
            } else {
                dict[firstLetter] = [vocabularyEntry]
            }
        }
        
        return dict
    }
    
    static func alphabetizedKeys(for vocabulary: [VocabularyEntry]) -> [String] {
        return alphabetizedDictionary(for: vocabulary).keys.sorted()
    }
    
    static func alphabetizedVocabulary(for vocabulary: [VocabularyEntry]) -> [[VocabularyEntry]] {
        var result = [[VocabularyEntry]]()
        for key in alphabetizedKeys(for: vocabulary) {
            result.append(alphabetizedDictionary(for: vocabulary)[key]!)
        }
        return result
    }
}
