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
        VStack(spacing: 50) {
            HStack(spacing: 20) {
                ProgressBar(progression: viewModel.progression)
                    .progressBarStyle(DefaultProgressBarStyle(), fillColor: .commonGreen)
                    .frame(height: 14)
                    .animation(.easeIn, value: viewModel.progression)
                Button {
                    isPresenting = false
                } label: {
                    Text("END")
                }.buttonStyle(QuizUtilityButtonStyle(buttonColor: .morningDustBlue))
            }
            .frame(height: 20)
            if let dataSource = viewModel.dataSource {
                HStack(spacing: 0) {
                    ForEach(dataSource, id: \.?.id) { quiz in
                        if let question = quiz {
                            QuestionView(viewModel: viewModel, question: question, submission: submission)
                        } else {
                            GeometryReader { proxy in
                                proxyTrigger(proxy)
                            }
                        }
                    }
                    .frame(minWidth: Constant.screenBounds.width)
                    .animation(nil, value: dataSource)
                    .animation(.linear, value: offset)
                    .offset(x: offset)
                }
            }
        }
        .padding(30)
        .interactiveDismissDisabled(!viewModel.quizDidFinish)
    }
    
    private func proxyTrigger(_ proxy: GeometryProxy) -> some View {
        let frame = proxy.frame(in: .global)
        if frame.minX == 0 {
            viewModel.progressViewIsInView()
        }
        return ReportView(viewModel: viewModel.getProgressViewModel())
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
