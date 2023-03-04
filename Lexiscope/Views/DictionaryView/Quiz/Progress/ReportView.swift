//
//  ReportView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/8/23.
//

import SwiftUI

struct ReportView: View {
    @ObservedObject var viewModel: ProgressViewModel
    
    init(viewModel: ProgressViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ProgressReport()
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(viewModel.progressEntries, id: \.self.title) { entry in
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
                                        .font(.callout.bold())
                                        .foregroundColor(progressColor(for: entry.step))
                                        .progressCellAnimation(with: entry.step)
                                    Spacer()
                                }
                                if showSummary(for: entry) {
                                    Text(entry.summary ?? "")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(progressColor(for: entry.step).opacity(0.3), lineWidth: 4)
                                .background(progressColor(for: entry.step).opacity(0.1))
                                .clipped()
                                .progressCellAnimation(with: entry.step)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
            }
        }.padding(50)
    }
    
    private static let progressGradient: [Color] = [.bittersweet, .orange, .mikadoYellow, .green, .boyBlue]
    
    private func progressColor(for step: Double) -> Color {
        ReportView.progressGradient[Int(step)]
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
