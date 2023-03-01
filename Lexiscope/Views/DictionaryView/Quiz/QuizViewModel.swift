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
    var quizResults: [Bool]
    
    init() {
        self.quiz = Quiz(orderedVocabulary: [])
        self.vocabularyEntries = []
        self.totalQuestions = 0
        self.currentQuestionIndex = 0
        self.quizResults = [Bool]()
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
            quizResults.append(validity)
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
