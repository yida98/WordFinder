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
                    HStack(spacing: 14) {
                        VStack {
                            Text("New familiars")
                                .font(.caption)
                                .foregroundColor(.verdigrisLight)
                            Text("\(newFamiliars)")
                                .font(.subheadline.bold())
                                .foregroundColor(.verdigrisLight)
                                .animation(.linear, value: newFamiliars)
                        }
                        
                        VStack {
                            Text("Total familiar")
                                .font(.caption)
                                .foregroundColor(.verdigrisLight)
                            Text("\(totalFamiliar)")
                                .font(.subheadline.bold())
                                .foregroundColor(.verdigrisLight)
                                .animation(.linear, value: totalFamiliar)
                        }
                    }
                    
                    HStack {
                        ProgressBar(progression: CGFloat(percent))
                            .progressBarStyle(DefaultProgressBarStyle(), fillColor: .commonGreen, backgroundColor: .commonGreen.opacity(0.3))
                            .frame(height: 8)
                            .animation(.linear, value: percent)
                        Text("\(percentage())%")
                            .font(.caption)
                            .foregroundColor(.verdigrisLight)
                            .animation(.linear, value: percent)
                    }
                }
            }//.boxStyle(DefaultBoxStyle())
        }
    }
    
    private func percentage() -> String {
        String(format: "%.1f", percent * 100)
    }
}
