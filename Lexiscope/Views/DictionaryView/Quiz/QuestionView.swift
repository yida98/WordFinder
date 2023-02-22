//
//  QuestionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/3/23.
//

import SwiftUI

struct QuestionView: View {
    @ObservedObject var viewModel: QuizViewModel
    @State private var choice: Int?
    @State private var canSubmit: Bool = false
    @State private var validation: [Bool]?
    var question: Quiz.Entry
    var submission: () -> Void
    
    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 20) {
                HStack {
                    Text("\(question.getQueryTitle())")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.7))
                    Spacer()
                }
                Text("\(question.getQuestionDisplayString())")
                    .font(.title)
                    .foregroundColor(Color(white: 0.4))
            }
            VStack(spacing: 20) {
                ForEach(0..<4) { id in
                    QuizOptionCell(text: question.getDisplayString(for: id),
                                   id: id,
                                   choice: $choice,
                                   validation: validation)
                }
            }
            Button {
                viewModel.feedback(for: validation?[choice!])
                if validation == nil {
                    validation = viewModel.submit(choice)
                } else {
                    viewModel.next()
                }
                submission()
            } label: {
                if validation == nil {
                    Text("Submit")
                } else {
                    Text("Next →")
                }
            }
            .disabled(!canSubmit)
            .buttonStyle(QuizButtonStyle(shape: RoundedRectangle(cornerRadius: 16),
                                         primaryColor: getPrimarySubmitButtonColor(),
                                         secondaryColor: getSecondarySubmitButtonColor(),
                                         disabled: !canSubmit))
            Spacer()
        }
        .frame(maxWidth: Constant.screenBounds.width - 80)
        .onChange(of: choice) { newValue in
            canSubmit = newValue != nil
        }
    }
    
    private func resetQuiz() {
        choice = nil
        canSubmit = false
        validation = nil
    }
    
    private func getPrimarySubmitButtonColor() -> Color {
        guard canSubmit else { return .init(white: 0.95) }
        guard let validation = validation, let choice = choice, !validation[choice] else { return .yellowGreenCrayola }
        return .red
    }
    
    private func getSecondarySubmitButtonColor() -> Color {
        guard canSubmit else { return .init(white: 0.85) }
        guard let validation = validation, let choice = choice, !validation[choice] else { return .darkSeaGreen }
        return .redwood
    }
}
