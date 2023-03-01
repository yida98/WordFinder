//
//  Quiz.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/1/23.
//

import Foundation

class Quiz {
    /// Descending
    private var orderedVocabulary: [VocabularyEntry]
    
    init(orderedVocabulary: [VocabularyEntry]) {
        self.orderedVocabulary = orderedVocabulary
    }
    
    func getNewQuestion(for queryType: Quiz.Entry.QueryType, at index: Int) -> Entry? {
        if index < orderedVocabulary.count {
            let question = orderedVocabulary[index]
            return makeQuizEntry(topic: question, allOtherOptions: orderedVocabulary, queryType: queryType)
        }
        return nil
    }
    
    private func makeQuizEntry(topic: VocabularyEntry, allOtherOptions: [VocabularyEntry], queryType: Quiz.Entry.QueryType) -> Entry {
        let options = Quiz.randomOptions(from: allOtherOptions)
        return Entry(topic: topic, options: options, queryType: queryType)
    }
    
    private static func makeOptions(from existingEntries: [VocabularyEntry], queryType: Entry.QueryType) -> [Sense] {
        let shuffledEntries = existingEntries.filter { $0.getHeadwordEntry().hasSense() }.shuffled()
        var results = [Sense]()
        for index in 0..<3 {
            results.append(Quiz.randomSense(from: shuffledEntries[index])!)
        }
        return results
    }
    
    /// Might not fulfill result.count == 3
    private static func randomOptions(from existingEntries: [VocabularyEntry]) -> [VocabularyEntry] {
        let shuffledEntries = existingEntries.filter { $0.getHeadwordEntry().hasSense() }.shuffled()
        var results = [VocabularyEntry]()
        for index in 0..<2 {
            if index < shuffledEntries.count {
                results.append(shuffledEntries[index])
            }
        }
        return results
    }
    
    static func randomSense(from vocabulary: VocabularyEntry) -> Sense? {
        let headwordEntry = vocabulary.getHeadwordEntry()
        let allSenses = headwordEntry.lexicalEntries.compactMap { $0.allSenses() }.flatMap { $0 }
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
        
        /// Always has 4
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
                self.choiceStrings = randomizedOptions.compactMap { Quiz.randomSense(from: $0)?.definitions?.first }
            case .match:
                self.topicString = Quiz.randomSense(from: topic)?.definitions?.first ?? ""
                self.choiceStrings = randomizedOptions.compactMap { $0.word }
            }
        }
        
        func getDisplayString(for index: Int) -> String {
            guard index < choiceStrings.count else { return "" }
            return choiceStrings[index]
        }
        
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
        
        private static func makeOptions(for topic: VocabularyEntry, from options: [VocabularyEntry]) -> [VocabularyEntry] {
            var allAnswers = options.shuffled()
            guard let answer = [0,1,2,3].randomElement() else { fatalError("Cannot get a random location") }
            if allAnswers.count < 3 {
                for _ in 0..<(3 - allAnswers.count) {
                    allAnswers.append(topic)
                }
            }
            allAnswers.insert(topic, at: answer)
            return allAnswers
        }
        
        func validate(vocabularyEntry: VocabularyEntry?) -> Bool {
            guard let vocabularyEntry = vocabularyEntry else { return false }
            return topic.word == vocabularyEntry.word
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
