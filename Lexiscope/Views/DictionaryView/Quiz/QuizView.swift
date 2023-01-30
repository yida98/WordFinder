//
//  QuizView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/30/23.
//

import SwiftUI

struct QuizView: View {
    
    @StateObject var viewModel = QuizViewModel()
    
    var body: some View {
        VStack {
            Text("Question")
            VStack {
                HStack {
                    Text("1")
                    Text("2")
                }
                HStack {
                    Text("3")
                    Text("4")
                }
            }
        }
    }
}
