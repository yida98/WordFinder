//
//  QuizView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct QuizView: View {
    
    @StateObject var viewModel = QuizViewModel()
    @State var choice: Int?
    @State var canSubmit: Bool = false
    
    var body: some View {
        if let question = viewModel.question {
            VStack(spacing: 20) {
                Text("\(question.text)")
                VStack {
                    ForEach(0..<4) { id in
                        QuizOptionCell(text: viewModel.option(id, for: question), id: id, choice: $choice)
                    }
                }
                Button {
                    let result = viewModel.validate(choice)
                    switch result {
                    case .success(let success):
                        print("\(success)")
                    case .failure(let failure):
                        print("wrong")
                    }
                } label: {
                    Text("Submit")
                }
                .disabled(!canSubmit)
                .buttonStyle(QuizButtonStyle(shape: RoundedRectangle(cornerRadius: 20),
                                             primaryColor: canSubmit ? .yellowGreenCrayola : .init(white: 0.95),
                                             secondaryColor: canSubmit ? .darkSeaGreen : .init(white: 0.85),
                                             disabled: !canSubmit))
            }
            .background(Color.babyPowder)
            .onChange(of: choice) { newValue in
                canSubmit = newValue != nil
            }
        } else {
            Text("placeholder view")
        }
    }
}
