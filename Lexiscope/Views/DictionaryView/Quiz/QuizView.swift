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
    
    @State private var shouldShowProgression: Bool = true
    @State private var offset: CGFloat = 0
    
    var body: some View {
            VStack(spacing: 50) {
                HStack(spacing: 20) {
                    ProgressBar(progression: viewModel.progression)
                        .progressBarStyle(DefaultProgressBarStyle(), fillColor: .celadon, backgroundColor: .celadon.opacity(0.3))
                        .frame(height: 14) // TODO: Magic value
                        .animation(.easeIn, value: viewModel.progression)
                        .opacity(shouldShowProgression ? 1 : 0)
                        .animation(.linear(duration: 0.2), value: shouldShowProgression)
                    Button {
                        if viewModel.progressFirstAppearance || viewModel.quizResults.count == 0 {
                            isPresenting = false
                        } else {
                            endQuiz()
                        }
                    } label: {
                        Text("END")
                            .font(.captionQuiz)
                    }.buttonStyle(QuizUtilityButtonStyle(buttonColor: .gradient3a))
                }
                .frame(height: 20)
                .padding(30)
                if let dataSource = viewModel.dataSource {
                    HStack(spacing: 0) {
                        ForEach(dataSource, id: \.id) { question in
                            GeometryReader { proxy in
                                QuestionView(viewModel: viewModel, question: question, preparation: preparation, submission: submission)
                                    .onChange(of: proxy.frame(in: .global)) { newValue in
                                        if newValue.minX == 0 {
                                            removeExtraneousDataSources()
                                        }
                                    }.frame(width: Constant.screenBounds.width, alignment: .center)
                                    .animation(nil, value: dataSource)
                                    
                            }.frame(width: Constant.screenBounds.width, alignment: .center)
                        }
                        if viewModel.quizDidFinish {
                            GeometryReader { proxy in
                                proxyTrigger(proxy)
                                    .onChange(of: proxy.frame(in: .global)) { newValue in
                                        if newValue.minX == 0 {
                                            viewModel.progressViewIsInView()
                                            shouldShowProgression = false
                                        }
                                    }
                                    .frame(width: Constant.screenBounds.width)
                            }
                            .frame(width: Constant.screenBounds.width)
                        }
                    }
                    .frame(width: Constant.screenBounds.width)
                    .animation(.linear, value: offset)
                    .offset(x: offset)
                }
            }
            .interactiveDismissDisabled(!viewModel.quizDidFinish)
    }
    
    private func proxyTrigger(_ proxy: GeometryProxy) -> some View {
        let frame = proxy.frame(in: .global)
        /// Make sure the progressViewModel is created before calling progressViewIsInView
        let progressViewModel = viewModel.getProgressViewModel()
        if frame.minX == 0 {
            viewModel.progressViewIsInView()
        }
        return ReportView(viewModel: progressViewModel)
    }
    
    /// Prepare the next question
    private func preparation() {
        if let newQuestion = viewModel.newQuestion() {
            viewModel.dataSource.append(newQuestion)
        } else {
            viewModel.quizDidFinish = true
        }
        
        /// No animation
        offset = (Constant.screenBounds.width / 2)
    }
    
    /// Execute animation
    private func submission() {
        viewModel.progression = CGFloat(viewModel.currentQuestionIndex - 1) / CGFloat(viewModel.totalQuestions)
        withAnimation {
            offset = -(Constant.screenBounds.width / 2)
        }
    }
    
    private func removeExtraneousDataSources() {
        if offset < 0 {
            if let currentQuestion = viewModel.dataSource.last {
                viewModel.dataSource = [currentQuestion]
            }
            /// No animation
            offset = 0
        }
    }
    
    func endQuiz() {
        viewModel.endQuiz()
        submission()
    }
}
