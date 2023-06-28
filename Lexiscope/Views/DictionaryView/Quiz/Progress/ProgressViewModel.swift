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
    @Published var newFamiliars: Int
    @Published var totalFamiliar: Int
    @Published var percentGrade: Double
    
    @Published var presentingEntry: MWRetrieveGroup?
    
    init(vocabulary: [VocabularyEntry], validationStamps: [Bool]) {
        self.progressEntries = vocabulary.indices.map { ProgressEntry.makeProgressEntry(from: vocabulary[$0], valid: validationStamps[$0]) }
        self.validationStamps = validationStamps
        self.newFamiliars = 0
        self.totalFamiliar = ProgressViewModel.getTotalFamiliar()
        self.percentGrade = 0.0
    }
    
    func didEnterView() {
        for entryIndex in 0..<progressEntries.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                if let strongSelf = self {
                    strongSelf.progressEntries[entryIndex].step = strongSelf.getCurrentStep(forVocabularyEntryAt: entryIndex)
                    strongSelf.percentGrade = strongSelf.getPercentGrade()
                    if strongSelf.progressEntries[entryIndex].step >= 4 {
                        strongSelf.newFamiliars += 1
                    }
                }
            }
        }
    }
    
    static func getTotalFamiliar() -> Int {
        guard let allFamiliar = DataManager.shared.fetchAllFamiliar() else {
            return .zero
        }
        return allFamiliar.count
    }
    
    func getPercentGrade() -> Double {
        let validCount = self.validationStamps.reduce(into: 0) { partialResult, stamp in
            partialResult += stamp ? 1 : 0
        }
        
        return Double(validCount) / Double(validationStamps.count)
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
        let summary = vocabularyEntry.getHeadwordEntry().allShortDefs().first
        
        return ProgressEntry(title: title, step: step, summary: summary, valid: valid, vocabulary: vocabularyEntry)
    }
    
    private static func updateTimeStamp(for vocabularyEntry: VocabularyEntry, valid: Bool) {
        guard var dates = vocabularyEntry.recallDates else {
            vocabularyEntry.recallDates = valid ? [Date()] : nil
            return
        }
        
        if valid {
            if dates.count >= 4 {
                let start = dates.count - 3
                let end = dates.count
                dates = Array(dates[start..<end])
            }
            dates.append(Date())
            vocabularyEntry.recallDates = dates
        } else {
            vocabularyEntry.recallDates = nil
        }
        
    }
}
