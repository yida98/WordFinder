//
//  QuizView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct QuizView: View {
    
    @ObservedObject var viewModel: QuizViewModel
    
    @Binding var isPresenting: Bool
    
    @State private var counter1: Int = 0
    @State private var counter2: Int = 0
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                ProgressBar(numerator: viewModel.currentQuestionIndex + 1, denominator: viewModel.totalQuestions, height: 14)
                Button {
                    isPresenting = false
                } label: {
                    Text("END")
                }.buttonStyle(QuizUtilityButtonStyle(buttonColor: .morningDustBlue))
            }
            .frame(height: 20)
            .padding(30)
            if let dataSource = viewModel.dataSource {
                HStack(spacing: 0) {
                    ForEach(dataSource, id: \.?.id) { quiz in
                        if let question = quiz {
                            QuestionView(viewModel: viewModel, question: question, submission: submission)
                                .frame(minWidth: Constant.screenBounds.width)
                        } else {
                            Text("Progress View")
                                .frame(minWidth: Constant.screenBounds.width)
                        }
                    }
                    .animation(nil, value: dataSource)
                    .animation(.linear, value: offset)
                    .offset(x: offset)
                }
            }
        }.interactiveDismissDisabled(!viewModel.quizDidFinish)
    }
    
    private func submission() {
        if let dataSource = viewModel.dataSource {
            if counter1 == counter2 {
                if dataSource.count > 1 {
                    viewModel.dataSource?.remove(at: 0)
                }
                viewModel.dataSource?.append(viewModel.newQuestion())
                offset = CGFloat((viewModel.dataSource?.count ?? 1) - 1) * (Constant.screenBounds.width / 2)
                counter1 += 1
            } else {
                offset = CGFloat(dataSource.count - 1) * -(Constant.screenBounds.width / 2)
                counter2 += 1
            }
        }
    }
}
