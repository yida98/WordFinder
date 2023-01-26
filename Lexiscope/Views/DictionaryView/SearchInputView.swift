//
//  SearchInputView.swift
//  Lexiscope
//
//  Created by Yida Zhang on 1/25/23.
//

import SwiftUI

struct SearchInputView: View {
    @ObservedObject var viewModel: DictionaryViewModel
    @State private var text: String = ""
    @FocusState private var searchIsFocused: Bool
    
    var body: some View {
        VStack {
            HStack {
                TextField("Search", text: $text) {
                    viewModel.searchWord(text)
                }
                    .focused($searchIsFocused)
                    .submitLabel(text.count > 0 ? .search : .done)
                Button {
                    viewModel.searchWord(text)
                    searchIsFocused = false
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(searchIsFocused ? .blue : .thistle)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(searchIsFocused ? Color.boyBlue.opacity(0.05) : Color(white: 0.99))
            .mask {
                RoundedRectangle(cornerRadius: 16)
            }
            .onTapGesture {
                searchIsFocused = true
            }
            .animation(.default, value: 0.3)
            
            DefinitionView(viewModel: viewModel.getDefinitionViewModel(), expanded: $viewModel.expanded)
        }
        .padding(50)
    }
}
