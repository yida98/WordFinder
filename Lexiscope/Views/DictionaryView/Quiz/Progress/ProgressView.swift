//
//  ProgressView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 2/8/23.
//

import SwiftUI

struct ProgressView: View {
//    @ObservedObject var viewModel: QuizViewModel
    private static let colorSet1: ColorSet = .init(primaryFill: .yellowGreenCrayola, secondaryFill: .white, shadowFill: .darkSeaGreen, primaryHighlight: .hunterGreen)
    private static let colorSet2: ColorSet = .init(primaryFill: .yellow, secondaryFill: .white, shadowFill: .darkSeaGreen, primaryHighlight: .hunterGreen)
    private var colorSet: ColorSet = ProgressView.colorSet1
    
    @State var step: Double = 3
    private var thing: [(String, Double)] = [("ace", 1), ("base", 0), ("case", 2), ("dance", 4), ("ece", 3)]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10) {
                ForEach(thing, id: \.self.0) { th in
                    HStack(spacing: 8) {
                        VStack {
                            CompletionBadgeView(step: th.1, fillColor: progressColor(for: th.1))
                                .frame(width: 20, height: 20)
                            if th.1.truncatingRemainder(dividingBy: 2) == 0 {
                                Spacer()
                            }
                        }
                        VStack {
                            HStack {
                                Text(th.0)
                                    .font(.callout.bold())
                                    .foregroundColor(progressColor(for: th.1))
                                Spacer()
                            }
                            if th.1.truncatingRemainder(dividingBy: 2) == 0 {
                                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .stroke(progressColor(for: th.1).opacity(0.3), lineWidth: 4)
                            .background(progressColor(for: th.1).opacity(0.1))
                            .clipped()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                }
            }
        }.padding(50)
    }
    
    private static let progressGradient: [Color] = [.bittersweet, .orange, .mikadoYellow, .green, .boyBlue]
    
    private func progressColor(for step: Double) -> Color {
        ProgressView.progressGradient[Int(step)]
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView()
    }
}
