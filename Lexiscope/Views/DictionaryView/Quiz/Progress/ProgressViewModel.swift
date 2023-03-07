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
    private let validationStamps: [Bool]
    
    init(vocabulary: [VocabularyEntry], validationStamps: [Bool]) {
        self.progressEntries = vocabulary.indices.map { ProgressEntry.makeProgressEntry(from: vocabulary[$0], valid: validationStamps[$0]) }
        self.validationStamps = validationStamps
    }
    
    func didEnterView() {
        for entryIndex in 0..<progressEntries.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.progressEntries[entryIndex].step = self?.getCurrentStep(forVocabularyEntryAt: entryIndex) ?? 0.0
            }
        }
    }
    
    func getTotalFamiliar() -> Int {
        
        return .zero
    }
    
    func getPercentGrade() -> Double {
        let validCount = self.validationStamps.reduce(into: 0) { partialResult, stamp in
            partialResult += stamp ? 1 : 0
        }
        
        return Double(validCount / validationStamps.count)
    }
    
    private func getCurrentStep(forVocabularyEntryAt index: Int) -> Double {
        Double(progressEntries[index].vocabulary.recallDates?.count ?? 0)
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
        let step = Double((vocabularyEntry.recallDates?.count ?? 0) % 4)
        
        if valid != nil {
            updateTimeStamp(for: vocabularyEntry, valid: valid!)
        }

        let title = vocabularyEntry.word ?? ""
        let summary = vocabularyEntry.getHeadwordEntry().lexicalEntries.first?.allSenses().first?.definitions?.first
        
        return ProgressEntry(title: title, step: step, summary: summary, valid: valid, vocabulary: vocabularyEntry)
    }
    
    private static func updateTimeStamp(for vocabularyEntry: VocabularyEntry, valid: Bool) {
        guard var dates = vocabularyEntry.recallDates else {
            vocabularyEntry.recallDates = valid ? [Date()] : nil
            return
        }
        
        if valid {
            dates.append(Date())
            vocabularyEntry.recallDates = dates
        } else {
            vocabularyEntry.recallDates = nil
        }
        
//        DataManager.shared.resaveVocabularyEntry(vocabularyEntry)
    }
}
