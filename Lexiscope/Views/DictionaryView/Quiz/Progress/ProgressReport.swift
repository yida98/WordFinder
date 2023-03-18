//
//  ProgressReport.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/2/23.
//

import SwiftUI

struct ProgressReport: View {
    var newFamiliars: Int
    var totalFamiliar: Int
    var percent: Double
    
    var body: some View {
        HStack {
            Box {
                VStack {
                    HStack(spacing: 30) {
                        VStack {
                            Text("New familiars")
                                .font(.captionQuiz)
                                .foregroundColor(.white)
                            Text("\(newFamiliars)")
                                .font(.subheadlineQuiz.bold())
                                .foregroundColor(.white)
                                .animation(.linear, value: newFamiliars)
                        }
                        
                        VStack {
                            Text("Total familiar")
                                .font(.captionQuiz)
                                .foregroundColor(.white)
                            Text("\(totalFamiliar)")
                                .font(.subheadlineQuiz.bold())
                                .foregroundColor(.white)
                                .animation(.linear, value: totalFamiliar)
                        }
                    }
                    
                    HStack {
                        ProgressBar(progression: CGFloat(percent))
                            .progressBarStyle(DefaultProgressBarStyle(), fillColor: .green, backgroundColor: .green.opacity(0.3))
                            .frame(height: 8)
                            .animation(.linear, value: percent)
                        Text("\(percentage())%")
                            .font(.captionQuiz)
                            .foregroundColor(.white)
                            .animation(.linear, value: percent)
                    }
                }
            }.boxStyle(DefaultBoxStyle())
        }
    }
    
    private func percentage() -> String {
        String(format: "%.1f", percent * 100)
    }
}
