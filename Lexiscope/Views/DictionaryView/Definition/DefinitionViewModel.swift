//
//  DefinitionViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 12/14/22.
//

import Foundation
import Combine
import AVFoundation
import SwiftUI

class DefinitionViewModel: ObservableObject {
    
    @Published var headwordEntry: MWRetrieveEntry // Headword type
    @Published var saved: Bool
    @Published var expanded: Bool
    
    init(headwordEntry: MWRetrieveEntry, saved: Bool, expanded: Bool) { // Headword type
        self.headwordEntry = headwordEntry
        self.saved = saved
        self.expanded = expanded
    }
    
    var allValidPronunciations: [MWPronunciation] {
        headwordEntry.allPronunciations()
    }
    
    var inflectionString: String? {
        headwordEntry.inflectionLabel()
    }
    
    var definitions: def? {
        headwordEntry.def
    }
    
    func bookmarkWord() {
//        if DataManager.shared.fetchVocabularyEntry(for: headwordEntry) != nil {
//            saved = false
//            DataManager.shared.deleteVocabularyEntry(for: headwordEntry)
//        } else {
//            saved = true
//            let encoder = JSONEncoder()
//            do {
//                let headwordData = try encoder.encode(headwordEntry)
//                DataManager.shared.saveVocabularyEntryEntity(headwordEntry: headwordData, word: headwordEntry.getWord(), notes: nil, recallDates: nil)
//                
//                for url in headwordEntry.allPronunciationURLs() {
//                    URLTask.shared.downloadAudioFileData(from: url) { data, urlResponse, error in
//                        if let data = data {
//                            DataManager.shared.savePronunciation(url: url as NSURL, pronunciation: data)
//                        }
//                    }
//                }
//            } catch {
//                debugPrint("Cannot encode \(headwordEntry) entry into data.")
//            }
//        }
    }
}

extension Sense {
    func allSenses() -> [Sense]? {
        guard let subsenses = self.subsenses else { return [self] }
        var result = [self]
        result.append(contentsOf: subsenses.compactMap {
            return $0.allSenses()
        }.flatMap { $0 })
        return result
    }
}

extension LexicalEntry {
    func allSenses() -> [Sense] {
        self.entries.compactMap { $0.senses?.compactMap { $0.allSenses() }.flatMap { $0 } }.flatMap { $0 }
    }
}

extension HeadwordEntry {
    func allPronunciations() -> [InlineModel1]? {
        let phoneticSpellings = self.lexicalEntries.compactMap {
            $0.entries.compactMap {
                $0.pronunciations
            }.flatMap { $0 }
        }.flatMap { $0 }
        
        return phoneticSpellings.count > 0 ? phoneticSpellings : nil
    }
}

extension InlineModel1 {
    var hasAudio: Bool {
        return self.audioFile != nil
    }
}
