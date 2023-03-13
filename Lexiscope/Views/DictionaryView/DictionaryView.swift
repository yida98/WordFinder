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
//    @State private var text: String = ""
    @FocusState private var searchIsFocused: Bool
    @Binding var searchOpen: Bool
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    HStack {
                        TextField("Search from \(viewModel.vocabularySize)", text: $viewModel.textFilter) {
                            viewModel.handleNewRequest(viewModel.textFilter)
                            viewModel.textFilter = ""
                        }
                        .focused($searchIsFocused)
                        .submitLabel(viewModel.textFilter.count > 0 ? .search : .done)
                        if viewModel.textFilter.count > 0 {
                            Button {
                                searchIsFocused = false
                                viewModel.textFilter = ""
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
                    Toggle("Familiar", isOn: $viewModel.filterFamiliar).toggleStyle(StarToggleStyle())
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                TabView(selection: $viewModel.showingVocabulary) {
                    SavedWordsView(viewModel: viewModel.getSavedWordsViewModel())
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

struct StarToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Group {
            if configuration.isOn {
                Star(cornerRadius: 1)
                    .fill(Color.verdigris)
                    .frame(width: 20, height: 20)
            } else {
                Star(cornerRadius: 1)
                    .fill(Color.verdigrisLight)
                    .frame(width: 20, height: 20)
            }
        }
        .onTapGesture {
            configuration.isOn.toggle()
        }
    }
}
