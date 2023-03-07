//
//  ProgressReport.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/2/23.
//

import SwiftUI

struct ProgressReport: View {
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
                            Text("\(totalFamiliar)")
                                .font(.subheadline.bold())
                                .foregroundColor(.ultraViolet)
                        }
                        
                        VStack {
                            Text("Total familiar")
                                .font(.caption)
                            Text("\(totalFamiliar)")
                                .font(.subheadline.bold())
                                .foregroundColor(.ultraViolet)
                        }
                    }
                    
                    HStack {
                        ProgressBar(progression: CGFloat(percent))
                            .progressBarStyle(DefaultProgressBarStyle(), fillColor: .commonGreen)
                            .frame(height: 8)
                        Text("\(percentage())%")
                            .font(.caption)
                    }
                }
            }.boxStyle(DefaultBoxStyle())
        }
    }
    
    private func percentage() -> String {
        String(format: "%.1f", percent * 100)
    }
}
