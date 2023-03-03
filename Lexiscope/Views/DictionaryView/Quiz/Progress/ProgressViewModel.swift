//
//  ProgressViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/1/23.
//

import Foundation
import SwiftUI

class ProgressViewModel: ObservableObject {
    @Published var progressEntries: [ProgressEntry]
    
    init(vocabulary: [VocabularyEntry], validationStamps: [Bool]) {
        self.progressEntries = vocabulary.indices.map { ProgressEntry.makeProgressEntry(from: vocabulary[$0], valid: validationStamps[$0]) }
    }
    
    func didEnterView() {
        for entryIndex in 0..<progressEntries.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.progressEntries[entryIndex].step += 1
            }
        }
    }
}

struct ProgressEntry {
    var title: String
    var step: Double
    var summary: String?
    var valid: Bool?
    
    var vocabulary: VocabularyEntry
    
    init(title: String, step: Double, summary: String? = nil, valid: Bool? = nil, vocabulary: VocabularyEntry) {
        self.title = title
        self.step = step
        self.summary = summary
        self.valid = valid
        self.vocabulary = vocabulary
    }
    
    static func makeProgressEntry(from vocabularyEntry: VocabularyEntry, valid: Bool? = nil) -> ProgressEntry {
        let title = vocabularyEntry.word ?? ""
        let step = Double((vocabularyEntry.recallDates?.count ?? 0) % 4)
        let summary = vocabularyEntry.getHeadwordEntry().lexicalEntries.first?.allSenses().first?.definitions?.first
        
        return ProgressEntry(title: title, step: step, summary: summary, valid: valid, vocabulary: vocabularyEntry)
    }
}
