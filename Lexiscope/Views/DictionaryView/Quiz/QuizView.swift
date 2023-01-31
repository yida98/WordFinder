//
//  QuizView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct QuizView: View {
    @StateObject var viewModel = QuizViewModel() // TODO: @ObservedObject var viewModel: QuizViewModel
    @State var choice: Int?
    
    var body: some View {
        if let question = viewModel.question {
            VStack {
                Text("\(question.text)")
                GeometryReader { proxy in
                    VStack {
                        HStack {
                            QuizOptionCell(text: viewModel.option(0, for: question), id: 0, choice: $choice, parentGeometryProxy: proxy)
                            QuizOptionCell(text: viewModel.option(1, for: question), id: 1, choice: $choice, parentGeometryProxy: proxy)
                        }
                        HStack {
                            QuizOptionCell(text: viewModel.option(2, for: question), id: 2, choice: $choice, parentGeometryProxy: proxy)
                            QuizOptionCell(text: viewModel.option(3, for: question), id: 3, choice: $choice, parentGeometryProxy: proxy)
                        }
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
            }.background(.white)
        } else {
            Text("placeholder view")
        }
    }
}
