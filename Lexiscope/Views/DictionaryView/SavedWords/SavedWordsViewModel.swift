//
//  SavedWordsViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/17/23.
//

import Foundation

class SavedWordsViewModel: ObservableObject {
    
    @Published var vocabulary: [VocabularyEntry]?
    
    init() {
        fetchVocabList()
    }
    
    func fetchVocabList() {
        if let savedVocabulary = DataManager.shared.fetchSavedVocabulary() as? [VocabularyEntry] {
            vocabulary = savedVocabulary
        }
    }
}
