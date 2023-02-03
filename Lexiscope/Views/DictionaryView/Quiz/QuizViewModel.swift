//
//  QuizViewModel.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import Foundation
import UIKit

class QuizViewModel: ObservableObject {
    
    private var quiz: Quiz
    @Published var question: Quiz.Entry?
    
    init() {
        self.quiz = Quiz(dateOrderedVocabulary: [])
        if let dateOrderedVocabularyEntries = DataManager.shared.fetchDateOrderedVocabularyEntries(ascending: true) as? [VocabularyEntry] {
            self.quiz = Quiz(dateOrderedVocabulary: dateOrderedVocabularyEntries)
        }
        self.question = newQuestion()
    }
    
    private func newQuestion() -> Quiz.Entry? {
        quiz.getNewQuestion()
    }
    
    func option(_ option: Int, for entry: Quiz.Entry) -> String {
        guard let sense = entry.choices[option], let definitions = sense.definitions, let definition = definitions.first else { return "" }
        return definition
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
        return results
    }
    
    private func validate(_ option: Int?) -> Result<Bool, Error> {
        guard let question = question, let option = option else { return .failure(QuizError.noInput) }
        return .success(question.validate(sense: question.choices[option]))
        
    }
    
    func nextQuestion() {
        self.question = newQuestion()
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

struct Quiz {
    /// Descending
    private var dateOrderedVocabulary: [VocabularyEntry]
    
    init(dateOrderedVocabulary: [VocabularyEntry]) {
        self.dateOrderedVocabulary = dateOrderedVocabulary
    }
    
    mutating func getNewQuestion() -> Entry? {
        if let question = dateOrderedVocabulary.popLast() {
            return makeQuizEntry(topic: question, allOtherOptions: dateOrderedVocabulary)
        }
        return nil
    }
    
    private func makeQuizEntry(topic: VocabularyEntry, allOtherOptions: [VocabularyEntry]) -> Entry {
        let options = Quiz.randomOptions(from: allOtherOptions)
        return Entry(topic: topic, options: options)
    }
    
    private static func makeOptions(from existingEntries: [VocabularyEntry]) -> [Sense] {
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
    
    private static func randomSense(from vocabulary: VocabularyEntry) -> Sense? {
        let headwordEntry = vocabulary.getHeadwordEntry()
        let allSenses = headwordEntry.lexicalEntries.compactMap { $0.allSenses() }.flatMap { $0 }
        let shuffledSenses = allSenses.shuffled()
        return shuffledSenses.last
    }
    
    struct Entry: Equatable {
        private var topic: VocabularyEntry
        private var options: [VocabularyEntry]
        
        var text: String
        /// Always has 4
        var choices: [Sense?]
        
        init(topic: VocabularyEntry, options: [VocabularyEntry]) {
            self.topic = topic
            self.options = options
            self.text = topic.word!
            self.choices = Quiz.Entry.makeOptions(for: topic, from: options)
        }
        
        private static func makeOptions(for topic: VocabularyEntry, from options: [VocabularyEntry]) -> [Sense?] {
            var allAnswers = options.shuffled()
            guard let answer = [0,1,2,3].randomElement() else { fatalError("Cannot get a random location") }
            if allAnswers.count < 3 {
                for _ in 0..<(3 - allAnswers.count) {
                    allAnswers.append(topic)
                }
            }
            allAnswers.insert(topic, at: answer)
            return allAnswers.map { Quiz.randomSense(from: $0) }
        }
        
        func validate(sense: Sense?) -> Bool {
            guard let sense = sense else { return false }
            return !topic.getHeadwordEntry().allSenses().filter { $0.id == sense.id }.isEmpty
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
