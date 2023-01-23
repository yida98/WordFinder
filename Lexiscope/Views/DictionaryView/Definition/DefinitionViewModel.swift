//
//  DefinitionViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine

class DefinitionViewModel: ObservableObject {
    
    @Published var vocabularyEntry: VocabularyEntry?
    
    init(vocabularyEntry: VocabularyEntry? = nil) {
        if let vocabularyEntry = vocabularyEntry {
            self.vocabularyEntry = vocabularyEntry
        }
    }
    
    var retrieveEntry: RetrieveEntry? {
        if let vocabularyEntry = vocabularyEntry, let retrieveEntry = vocabularyEntry.retrieveEntry {
            return DataManager.decodedRetrieveEntryData(retrieveEntry)
        }
        return nil
    }
    
    func bookmarkWord() {
        if let vocabularyEntry = vocabularyEntry, let currWord = vocabularyEntry.word {
            DataManager.shared.bookmarkNewWord(currWord)
        }
    }
    
    func unbookmarkWord() {
        if let vocabularyEntry = vocabularyEntry, let currWord = vocabularyEntry.word {
            DataManager.shared.unbookmarkWord(currWord)
        }
        DataManager.shared.eraseCache()
    }
}
