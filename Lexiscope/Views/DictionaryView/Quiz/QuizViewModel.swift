//
//  QuizViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import Foundation
import UIKit
import SwiftUI

class QuizViewModel: ObservableObject {
    
    private var quiz: Quiz
    @Published var dataSource: [Quiz.Entry?]?
    private var vocabularyEntries: [VocabularyEntry]
    
    var queryType: Quiz.Entry.QueryType
    
    @Published var quizDidFinish: Bool = false
    var totalQuestions: Int
    @Published var currentQuestionIndex: Int
    
    init() {
        self.quiz = Quiz(orderedVocabulary: [])
        self.vocabularyEntries = []
        self.totalQuestions = 0
        self.currentQuestionIndex = 0
        if var dateOrderedVocabularyEntries = DataManager.shared.fetchDateOrderedVocabularyEntries(ascending: false) as? [VocabularyEntry] {
            dateOrderedVocabularyEntries.sort { lhs, rhs in
                if let lhsDates = lhs.recallDates, let rhsDates = rhs.recallDates {
                    if lhsDates.count == rhsDates.count {
                        return lhsDates.last ?? Date.distantPast < rhsDates.last ?? Date.distantPast
                    } else {
                        return lhsDates.count < rhsDates.count
                    }
                } else {
                    return lhs.recallDates == nil
                }
            }
            self.quiz = Quiz(orderedVocabulary: dateOrderedVocabularyEntries)
            self.vocabularyEntries = dateOrderedVocabularyEntries
            self.totalQuestions = dateOrderedVocabularyEntries.count
        }
        self.queryType = .define
        self.dataSource = [newQuestion()]
    }
    
    func newQuestion() -> Quiz.Entry? {
        quiz.getNewQuestion(for: queryType, at: currentQuestionIndex)
    }
    
    func submit(_ option: Int?) -> [Bool] {
        var results = [Bool]()
        for index in 0..<4 {
            switch validate(index) {
            case .success(let value):
                results.append(value)
            default:
                results.append(false)
            }
        }
        // TODO: Move to the end
        if let option = option, option < results.count {
            let validity = results[option]
            updateRecallDates(validity: validity)
        }
        currentQuestionIndex += 1
        return results
    }
    
    /// This happens before the currentQuestionIndex increments
    private func updateRecallDates(validity: Bool) {
        // 1-2-3-7
        let currentVocabulary = vocabularyEntries[currentQuestionIndex]
        let currentRecallDates = currentVocabulary.recallDates
        
        // If the prev dates follow the pattern of 1-2-3 then, just append
        // If the appending the new date won't follow the 1-2-3-7 pattern, reset
        // If new date is 1-2-3-4, remove 1 and add 4
        // If new date is earlier
        // If achieved 1-2-3-7, just keep adding
        
        guard let currentWord = currentVocabulary.word, let vocabularyManagedObject = DataManager.shared.fetchVocabularyEntry(for: currentWord.lowercased()) else {
            return
        }
        
    }
    
    func next() {
        if dataSource?.last == .some(nil) {
            quizDidFinish = true
        }
    }
    
    private func validate(_ option: Int?) -> Result<Bool, Error> {
        guard let dataSource = dataSource, let lastQuestion = dataSource.last, let question = lastQuestion, let option = option else { return .failure(QuizError.noInput) }
        return .success(question.validate(vocabularyEntry: question.choices[option]))
    }
    
    func feedback(for validation: Bool?) {
        let haptic = UINotificationFeedbackGenerator()
        guard let validation = validation else { haptic.notificationOccurred(.success); return }
        if validation {
            haptic.notificationOccurred(.error)
        } else {
            haptic.notificationOccurred(.success)
        }
    }
    
    enum QuizError: Error {
        case noInput
    }
}

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
