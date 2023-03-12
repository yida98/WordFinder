//
//  DictionaryView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 7/6/22.
//

import Foundation
import SwiftUI

struct DictionaryView: View {
    @ObservedObject var viewModel: DictionaryViewModel
    @State private var text: String = ""
    @FocusState private var searchIsFocused: Bool
    @Binding var searchOpen: Bool
    
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
                                .foregroundColor(.verdigris) // primary
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(searchIsFocused ? Color.boyBlue.opacity(0.05) : Color(white: 0.99))
                .mask {
                    RoundedRectangle(cornerRadius: 16)
                }
                .onTapGesture {
                    searchIsFocused = true
                    searchOpen = false
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
        }
    }
}
