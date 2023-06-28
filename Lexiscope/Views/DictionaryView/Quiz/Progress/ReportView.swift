//
//  ReportView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/8/23.
//

import SwiftUI

struct ReportView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    @State var isPresenting = false
    
    init(viewModel: ProgressViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(viewModel.progressEntries, id: \.self.title) { entry in
                        Button {
                            viewModel.presentingEntry = entry.vocabulary.getHeadwordEntry()
                            if viewModel.presentingEntry != nil {
                                isPresenting = true
                            }
                        } label: {
                            HStack(spacing: 8) {
                                VStack {
                                    CompletionBadgeView(step: entry.step, fillColor: progressColor(for: entry.step), validated: entry.valid)
                                        .frame(width: 20, height: 20)
                                    if showSummary(for: entry) {
                                        Spacer()
                                    }
                                }
                                VStack {
                                    HStack {
                                        Text(entry.title)
                                            .font(.calloutQuiz.bold())
                                            .foregroundColor(progressColor(for: entry.step))
                                            .progressCellAnimation(with: entry.step)
                                        Spacer()
                                    }
                                    if showSummary(for: entry) {
                                        Text(entry.summary ?? "")
                                            .font(.captionQuiz)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }.padding()
                        }
                        .buttonStyle(QuizButtonStyle(shape: RoundedRectangle(cornerRadius: 20),
                                                     primaryColor: .verdigrisLight,
                                                     secondaryColor: .verdigrisDark,
                                                     baseColor: .verdigrisDark,
                                                     disabled: false))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 4)
                    }
                }
            }
            ProgressReport(newFamiliars: viewModel.newFamiliars,
                           totalFamiliar: viewModel.totalFamiliar,
                           percent: viewModel.percentGrade)
        }
        .padding(.horizontal, 60)
        .sheet(isPresented: $isPresenting, onDismiss: {
            viewModel.presentingEntry = nil
        }, content: {
            if let entry = viewModel.presentingEntry {
                FullSavedWordView(viewModel: FullSavedWordViewModel(headwordEntry: entry, saved: true))
            } else {
                EmptyView()
            }
        })
    }
    
    private func progressColor(for step: Double) -> Color {
        let progressGradient: [Color] = [.orange, .sunglow, .green, .boyBlue]
        if step == 0 {
            return .bittersweet
        } else if step <= 4 {
            return progressGradient[Int(step - 1)]
        } else {
            return .boyBlue
        }
    }
    
    private func showSummary(for entry: ProgressEntry) -> Bool {
        guard let validity = entry.valid, !validity else { return false }
        return true
    }
}

struct ProgressCellAnimation<E: Equatable>: ViewModifier {
    var value: E
    
    func body(content: Content) -> some View {
        content
            .animation(.easeIn(duration: 0.5), value: value)
    }
}

extension View {
    func progressCellAnimation(with value: some Equatable) -> some View {
        modifier(ProgressCellAnimation(value: value))
    }
}
