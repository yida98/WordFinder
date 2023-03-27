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
    @Published var dataSource: [Quiz.Entry]
    private var vocabularyEntries: [VocabularyEntry]
    
    var queryType: Quiz.Entry.QueryType
    
    @Published var quizDidFinish: Bool = false
    var totalQuestions: Int
    @Published var currentQuestionIndex: Int
    @Published var progression: CGFloat
    var quizResults: [Bool]
    
    init(dateOrderedVocabularyEntries: [VocabularyEntry]) {
        self.quiz = Quiz(orderedVocabulary: dateOrderedVocabularyEntries)
        self.vocabularyEntries = dateOrderedVocabularyEntries
        self.totalQuestions = dateOrderedVocabularyEntries.count
        self.currentQuestionIndex = 0
        self.progression = 0
        self.quizResults = [Bool]()
        self.queryType = .define
        self.dataSource = [Quiz.Entry]()
        if let question = newQuestion() {
            dataSource = [question]
        }
    }
    
    static func getQuizzable() -> [VocabularyEntry]? {
        /// Don't quiz familiars unless there are only familiars left
        guard var dateOrderedVocabularyEntries = DataManager.shared.fetchDateOrderedVocabularyEntries(ascending: false) else { return nil }
        
        if let familiar = DataManager.shared.fetchAllFamiliar() {
            if familiar.count > 0 && familiar.count < dateOrderedVocabularyEntries.count {
                /// Check if already familiar
                dateOrderedVocabularyEntries = dateOrderedVocabularyEntries.filter {
                    if let recallDates = $0.recallDates {
                        return recallDates.count < 4
                    }
                    return true
                }
            }
        }
        
        /// Check if recently (yesterday) quizzed
        dateOrderedVocabularyEntries = dateOrderedVocabularyEntries.filter {
            if let dates = $0.recallDates, let last = dates.last {
                let calendar = Calendar.current
                return !calendar.isDateInToday(last)
            }
            return true
        }
        
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
        
        return dateOrderedVocabularyEntries
    }
    
    func newQuestion() -> Quiz.Entry? {
        let question = quiz.getNewQuestion(for: queryType, at: currentQuestionIndex)
        currentQuestionIndex += 1
        return question
    }
    
    func submit(_ option: Int?) -> [Bool] {
        switch validation() {
        case .success(let results):
            if let option = option, option < results.count {
                let validity = results[option]
                quizResults.append(validity)
                return results
            }
            return [Bool]()
        case .failure( _):
            return [Bool]()
        }
    }
    
    private func validation() -> Result<[Bool], Error> {
        guard let question = dataSource.last else { return .failure(QuizError.noInput) }
        return .success(question.validation())
    }
    
    private func validate(_ option: Int?) -> Result<Bool, Error> {
        guard let question = dataSource.last, let option = option else { return .failure(QuizError.noInput) }
        return .success(question.validate(vocabularyEntry: question.choices[option]))
    }
    
    func feedback(for validation: Bool?) {
        let haptic = UINotificationFeedbackGenerator()
        guard let validation = validation else { haptic.notificationOccurred(.success); return }
        if validation {
            haptic.notificationOccurred(.success)
        } else {
            haptic.notificationOccurred(.error)
        }
    }
    
    enum QuizError: Error {
        case noInput
    }
    
    private var progressViewModel: ProgressViewModel?
    
    func getProgressViewModel() -> ProgressViewModel {
        if progressViewModel == nil {
            self.progressViewModel = ProgressViewModel(vocabulary: vocabularyEntries, validationStamps: quizResults)
        }
        return self.progressViewModel!
    }
    
    var progressFirstAppearance: Bool = false
    func progressViewIsInView() {
        if !progressFirstAppearance {
            progressFirstAppearance = true
            progressViewModel?.didEnterView()
        }
    }
    
    func endQuiz() {
        let realIndex: Int = currentQuestionIndex - 1
        quiz.updateQuizSource(at: realIndex)
        vocabularyEntries = Array(vocabularyEntries[0..<realIndex])
        if let first = dataSource.first {
            dataSource = [first]
            quizDidFinish = true
        }
    }
}
