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
    @Published var saved: Bool?
    
    init(vocabularyEntry: VocabularyEntry? = nil) {
        if let vocabularyEntry = vocabularyEntry {
            self.vocabularyEntry = vocabularyEntry
            self.saved = vocabularyEntry.saved
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
            if vocabularyEntry.saved {
                DataManager.shared.unbookmarkWord(currWord)
            } else {
                DataManager.shared.bookmarkNewWord(currWord)
            }
            saved = vocabularyEntry.saved
        }
    }
}
