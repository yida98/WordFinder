//
//  Quiz.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/1/23.
//

import Foundation
import SwiftUI

class Quiz {
    /// Descending
    private var orderedVocabulary: [VocabularyEntry]
    
    init(orderedVocabulary: [VocabularyEntry]) {
        self.orderedVocabulary = orderedVocabulary
    }
    
    func updateQuizSource(at index: Int) {
        self.orderedVocabulary = Array(orderedVocabulary[0..<index])
    }
    
    func getNewQuestion(for queryType: Quiz.Entry.QueryType, at index: Int) -> Entry? {
        if index < orderedVocabulary.count, let allChoices = DataManager.shared.fetchVocabulary() {
            let question = orderedVocabulary[index]
            let allOtherOptions = allChoices.filter { $0.word != orderedVocabulary[index].word }
            return makeQuizEntry(topic: question, allOtherOptions: allOtherOptions, queryType: queryType)
        }
        return nil
    }
    
    private func makeQuizEntry(topic: VocabularyEntry, allOtherOptions: [VocabularyEntry], queryType: Quiz.Entry.QueryType) -> Entry {
        let options = Quiz.randomOptions(from: allOtherOptions)
        return Entry(topic: topic, options: options, queryType: queryType)
    }
    
    private static func makeOptions(from existingEntries: [VocabularyEntry], queryType: Entry.QueryType) -> [MWSenseSequence.Element.Sense] {
        let shuffledEntries = existingEntries.filter { $0.getHeadwordEntry().hasSense }.shuffled()
        var results = [MWSenseSequence.Element.Sense]()
        for index in 0..<3 {
            results.append(Quiz.randomSense(from: shuffledEntries[index])!)
        }
        return results
    }
    
    /// Might not fulfill result.count == 3
    private static func randomOptions(from allOtherOptions: [VocabularyEntry]) -> [VocabularyEntry] {
        let shuffledEntries = allOtherOptions.filter { $0.getHeadwordEntry().hasSense }.shuffled()
        var results = [VocabularyEntry]()
        for index in 0...2 {
            if index < shuffledEntries.count {
                results.append(shuffledEntries[index])
            }
        }
        return results
    }
    
    static func randomSense(from vocabulary: VocabularyEntry) -> MWSenseSequence.Element.Sense? {
        let headwordEntry = vocabulary.getHeadwordEntry()
        let allSenses = headwordEntry.allSenses()
        let shuffledSenses = allSenses.shuffled()
        return shuffledSenses.last
    }
    
    class Entry: Equatable {
        static func == (lhs: Quiz.Entry, rhs: Quiz.Entry) -> Bool {
            lhs.topic.word == rhs.topic.word
        }
        
        var id: UUID
        
        private var topic: VocabularyEntry
        private var options: [VocabularyEntry]
        
        /// Not always 4
        var choices: [VocabularyEntry]
        private var choiceStrings: [String]
        private var topicString: String
        private var queryType: QueryType
        
        init(topic: VocabularyEntry, options: [VocabularyEntry], queryType: QueryType) {
            self.id = UUID()
            self.topic = topic
            self.options = options
            
            let randomizedOptions = Quiz.Entry.makeOptions(for: topic, from: options)
            self.choices = randomizedOptions
            self.queryType = queryType
            switch queryType {
            case .define:
                self.topicString = topic.word ?? ""
                self.choiceStrings = randomizedOptions.compactMap { Quiz.randomSense(from: $0)?.dt.text }
            case .match:
                self.topicString = Quiz.randomSense(from: topic)?.dt.text ?? "!!red herring!!"
                self.choiceStrings = randomizedOptions.compactMap { $0.word }
            }
        }
        
        func getDisplayString(for index: Int) -> String {
            guard index < choiceStrings.count else { return Quiz.Entry.herrings[3 - index] }
            let result = choiceStrings[index]
            if result == "" {
                return " "
            }
            return result
        }
        
        private static let herrings = ["a decision by a court to approve a demotion or release.",
                                       "concerned with and directed by currents or currents.",
                                       "a dish of fried onions or chopped tomatoes with seasoning, breadcrumbs, and cheese."]
        
        func getQuestionDisplayString() -> String {
            topicString
        }
        
        func getQueryTitle() -> String {
            switch queryType {
            case .define:
                return "Define the following:"
            case .match:
                return "Match the definition:"
            }
        }
        
        func getPronunciationURL() -> URL? {
            return topic.getHeadwordEntry().allPronunciationURLs().first
        }
        
        /// The number of options is between 1 and 4
        private static func makeOptions(for topic: VocabularyEntry, from options: [VocabularyEntry]) -> [VocabularyEntry] {
            var allAnswers = options
            allAnswers.append(topic)
            allAnswers.shuffle()
            return allAnswers
        }
        
        func validate(vocabularyEntry: VocabularyEntry?) -> Bool {
            guard let vocabularyEntry = vocabularyEntry else { return false }
            return topic.word == vocabularyEntry.word
        }
        
        func validation() -> [Bool] {
            var results = [Bool]()
            for choice in choices {
                results.append(validate(vocabularyEntry: choice))
            }
            while results.count < 4 {
                results.append(false)
            }
            return results
        }
        
        enum QueryType {
            case define
            case match
        }
    }
}

extension Array {
    func removed(at index: Int) -> [Element] {
        var newArray = self
        newArray.remove(at: index)
        return newArray
    }
}

extension HeadwordEntry {
    func allSenses() -> [Sense] {
        self.lexicalEntries.compactMap { $0.allSenses() }.flatMap { $0 }
    }
    
    func hasSense() -> Bool {
        return self.allSenses().count > 0
    }
}
