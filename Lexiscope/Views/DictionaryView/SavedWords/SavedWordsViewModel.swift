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
    var dataManager: DataManager
    var dataManagerSubscriber: AnyCancellable?
    
    init() {
        self.dataManager = DataManager.shared
        dataManagerSubscriber = dataManager.objectWillChange.sink { [weak self] _ in
            self?.fetchVocabList()
        }
        fetchVocabList()
    }
    
    func fetchVocabList() {
        if let savedVocabulary = DataManager.shared.fetchVocabulary() as? [VocabularyEntry] {
            DispatchQueue.main.async { [weak self] in
                self?.vocabularyDictionary = SavedWordsViewModel.alphabetizedDictionary(for: savedVocabulary)
                self?.vocabulary = SavedWordsViewModel.alphabetizedVocabulary(for: savedVocabulary)
                self?.sectionTitles = SavedWordsViewModel.alphabetizedKeys(for: savedVocabulary).map { String($0) }
            }
        }
    }
    
    static func alphabetizedDictionary(for vocabulary: [VocabularyEntry]) -> [String: [VocabularyEntry]] {
        var dict = [String: [VocabularyEntry]]()
        for vocabularyEntry in vocabulary {
            let firstLetter = String(vocabularyEntry.word!.first!)
            if dict.keys.contains(firstLetter) {
                var array = dict[firstLetter]
                array!.append(vocabularyEntry)
                array!.sort(by: { $0.word! < $1.word! })
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
