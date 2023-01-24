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
    
    @Published var vocabulary: [VocabularyEntry]?
    @Published var expanded: Bool = false
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
        if let savedVocabulary = DataManager.shared.fetchSavedVocabulary() as? [VocabularyEntry] {
            DispatchQueue.main.async {
                self.vocabulary = savedVocabulary
            }
        }
    }
}
