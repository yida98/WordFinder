//
//  QuestionView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/3/23.
//

import SwiftUI
import AVFoundation

struct QuestionView: View {
    @ObservedObject var viewModel: QuizViewModel
    @State private var choice: Int?
    @State private var canSubmit: Bool = false
    @State private var temporarySubmissionBlock: Bool = false
    @State private var validation: [Bool]?
    var question: Quiz.Entry
    var preparation: () -> Void
    var submission: () -> Void
    
    var body: some View {
        VStack(spacing: 60) {
            VStack(spacing: 20) {
                HStack {
                    Text("\(question.getQueryTitle())")
                        .font(.subheadlineQuiz.bold())
                        .foregroundColor(Color.pineGreen)
                    Spacer()
                }
                Text("\(question.getQuestionDisplayString())")
                    .font(.largeTitleQuiz)
                    .foregroundColor(.verdigrisLight)
                    .onTapGesture {
                        if let url = question.getPronunciationURL() {
                            DataManager.shared.pronounce(url: url)
                        }
                    }
            }
            VStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { id in
                    QuizOptionCell(text: question.getDisplayString(for: id),
                                   id: id,
                                   choice: $choice,
                                   validation: validation)
                }
            }
            Button {
                viewModel.feedback(for: validation?[choice!])
                temporarySubmissionBlock = true
                if validation == nil {
                    validation = viewModel.submit(choice)
                    if let v = validation, let c = choice, v[c] {
                        AudioServicesPlaySystemSound(1103)
                    } else {
                        AudioServicesPlaySystemSound(1104)
                    }
                    preparation()
                } else {
                    submission()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.temporarySubmissionBlock = false
                }
            } label: {
                Group {
                    if validation == nil {
                        Text("Submit")
                    } else {
                        Text("Next →")
                    }
                }
                .padding()
            }
            .disabled(!canSubmit)
            .disabled(temporarySubmissionBlock)
            .buttonStyle(QuizButtonStyle(shape: RoundedRectangle(cornerRadius: 16),
                                         primaryColor: getPrimarySubmitButtonColor(),
                                         secondaryColor: getSecondarySubmitButtonColor(),
                                         baseColor: getSecondarySubmitButtonColor(),
                                         disabled: !canSubmit))
            .animation(nil, value: canSubmit)
            Spacer()
        }
        .frame(maxWidth: Constant.screenBounds.width - 60)
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
        guard canSubmit else { return .init(white: 0.85) }
        guard let validation = validation, let choice = choice, !validation[choice] else { return .commonGreen }
        return .red
    }
    
    private func getSecondarySubmitButtonColor() -> Color {
        guard canSubmit else { return .init(white: 0.65) }
        guard let validation = validation, let choice = choice, !validation[choice] else { return .pineGreen }
        return .redwood
    }
}
