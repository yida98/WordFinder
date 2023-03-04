//
//  ProgressReport.swift
//  Lexiscope
//
//  Created by Yida Zhang on 3/2/23.
//

import SwiftUI

struct ProgressReport: View {
    var body: some View {
        HStack {
            Box {
                VStack {
                    HStack {
                        Text("4/5")
                    }
                    ProgressBar(progression: 0.2)
                        .progressBarStyle(DefaultProgressBarStyle(), fillColor: .white)
                        .frame(height: 8)
                }
            }
            .boxStyle(ColouredBoxStyle(color: Color.green))
            Box {
                HStack {
                    Image(systemName: "clock.fill")
                    Text("5:40\"")
                }
            }
            .boxStyle(ColouredBoxStyle(color: Color.red))
            Box {
                HStack {
                    CompletionBadgeView(step: 4, fillColor: .white, strokeColor: .boyBlue, validated: true)
                        .frame(width: 20, height: 20)
                    Text("8")
                }
            }
            .boxStyle(ColouredBoxStyle(color: Color.boyBlue))
        }
    }
    
    private enum ResultCategory: CaseIterable {
        case validRatio, time, familiarityCount
    }
    
}

struct ProgressReport_Previews: PreviewProvider {
    static var previews: some View {
        ProgressReport()
    }
}
