//
//  QuizView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct QuizView: View {
    
    @ObservedObject var viewModel: QuizViewModel
    @State private var choice: Int?
    @State private var canSubmit: Bool = false
    @State private var validation: [Bool]?
    
    var body: some View {
        if let question = viewModel.question {
            HStack {
                Spacer()
                VStack(spacing: 60) {
                    Spacer()
                    VStack(spacing: 20) {
                        HStack {
                            Text("\(queryTitle())")
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
                            QuizOptionCell(text: viewModel.option(id, for: question),
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
                            viewModel.nextQuestion()
                            resetQuiz()
                        }
                    } label: {
                        if validation == nil {
                            Text("Submit")
                        } else {
                            Text("Next →")
                        }
                    }
                    .disabled(!canSubmit)
                    .buttonStyle(QuizButtonStyle(shape: RoundedRectangle(cornerRadius: 16),
                                                 primaryColor: canSubmit ? .yellowGreenCrayola : .init(white: 0.95),
                                                 secondaryColor: canSubmit ? .darkSeaGreen : .init(white: 0.85),
                                                 disabled: !canSubmit))
                    Spacer()
                }
                .frame(maxWidth: Constant.screenBounds.width - 80)
                Spacer()
            }
            .background(Color.white)
            .onChange(of: choice) { newValue in
                canSubmit = newValue != nil
            }
            .animation(.linear, value: viewModel.question)
        } else {
            Text("placeholder view")
        }
    }
    
    private func resetQuiz() {
        choice = nil
        canSubmit = false
        validation = nil
    }
    
    private func queryTitle() -> String {
        switch viewModel.queryType {
        case .define:
            return "Define the following:"
        case .match:
            return "Match the definition:"
        }
    }
}
