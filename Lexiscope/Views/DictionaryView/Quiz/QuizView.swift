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
    
    var body: some View {
        if let question = viewModel.question {
            VStack {
                Text("\(question.text)")
                VStack {
                    HStack {
                        QuizOptionCell(text: viewModel.option(0, for: question), id: 0, choice: $choice)
                        QuizOptionCell(text: viewModel.option(1, for: question), id: 1, choice: $choice)
                    }
                    HStack {
                        QuizOptionCell(text: viewModel.option(2, for: question), id: 2, choice: $choice)
                        QuizOptionCell(text: viewModel.option(3, for: question), id: 3, choice: $choice)
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
            }
        } else {
            Text("placeholder view")
        }
    }
}
