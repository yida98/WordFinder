//
//  DictionaryView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/6/22.
//

import Foundation
import SwiftUI

struct DictionaryView: View {
    @StateObject var viewModel: DictionaryViewModel = DictionaryViewModel()
    @State private var text: String = ""
    @FocusState private var searchIsFocused: Bool
    @StateObject var quizViewModel = QuizViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TextField("Search from \(viewModel.vocabularySize)", text: $text) {
                        viewModel.handleNewRequest(text)
                        text = ""
                    }
                    .focused($searchIsFocused)
                    .submitLabel(text.count > 0 ? .search : .done)
                    if text.count > 0 {
                        Button {
                            searchIsFocused = false
                            text = ""
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.thistle)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(searchIsFocused ? Color.boyBlue.opacity(0.05) : Color(white: 0.99))
                .mask {
                    RoundedRectangle(cornerRadius: 16)
                }
                .onTapGesture {
                    searchIsFocused = true
                    viewModel.showingVocabulary = true
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                TabView(selection: $viewModel.showingVocabulary) {
                    SavedWordsView(viewModel: viewModel.getSavedWordsViewModel(), text: $text)
                        .tag(true)
                    
                    SearchInputView(viewModel: viewModel)
                        .tag(false)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .animation(.easeIn(duration: 0.5), value: viewModel.showingVocabulary)
                .ignoresSafeArea(.keyboard)
            }
            VStack {
                Spacer()
                HStack {
                    Button {
                        viewModel.openQuiz()
                    } label: {
                        Text("Familiarity: \(viewModel.vocabularySize)")
                            .padding(4)
                            .padding(.horizontal, 5)
                            .background(Color.boyBlue)
                            .cornerRadius(10)
                            .font(.footnote)
                            .foregroundColor(.babyPowder)
                    }
                    Spacer()
                }
            }
            .padding(.leading, 40)
            .padding(.bottom, 15)
            .sheet(isPresented: $viewModel.isPresentingQuiz) {
                QuizView(viewModel: quizViewModel)
            }
        }
    }
}
